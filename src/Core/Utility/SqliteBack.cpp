
#include "SqliteBack.h"

#include "CycException.h"
#include "Logger.h"
#include "Event.h"

#include <iostream>
#include <fstream>

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
SqliteBack::SqliteBack(std::string filename){
  path_ = filename;
  db_ = new SqliteDb(path_);
  db_->overwrite();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
SqliteBack::~SqliteBack() {
  delete db_;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void SqliteBack::notify(EventList evts) {
  for (EventList::iterator it = evts.begin(); it != evts.end(); it++) {
    if (! tableExists(*it) ) {
      createTable(*it);
    }
    writeEvent(*it);
  }
  flush();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void SqliteBack::close() {
  flush();
  db_->close();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
std::string SqliteBack::name() {
  return path_;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void SqliteBack::createTable(event_ptr e){
  std::string name = e->name();
  tbl_names_.push_back(name);

  std::string cmd = "CREATE TABLE " + name + " (";

  ValMap vals = e->vals();
  ValMap::iterator it = vals.begin();
  while (true) {
    cmd += it->first + " " + valType(it->second);
    ++it;
    if (it == vals.end()) {
      break;
    }
    cmd += ", ";
  }

  cmd += ");";
  cmds_.push_back(cmd);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
std::string SqliteBack::valType(boost::any v) {
  if (v.type() == typeid(int)) {
    return "INTEGER";
  } else if (v.type() == typeid(float)) {
    return "REAL";
  } else if (v.type() == typeid(double)) {
    return "REAL";
  } else if (v.type() == typeid(std::string)) {
    return "VARCHAR(128)";
  }
  return "VARCHAR(128)";
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
bool SqliteBack::tableExists(event_ptr e) {
  std::string nm = e->name();
  if (find(tbl_names_.begin(), tbl_names_.end(), nm) != tbl_names_.end()) {
    return true;
  }
  return false;
}



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void SqliteBack::writeEvent(event_ptr e){
  std::stringstream cs, vs, cmd;
  ValMap vals = e->vals();
  ValMap::iterator it = vals.begin();
  while (true) {
    cs << it->first;
    vs << valData(it->second);
    ++it;
    if (it == vals.end()) {
      break;
    }
    cs << ", ";
    vs << ", ";
  }

  cmd << "INSERT INTO " << e->name() << " (" << cs.str() << ") "
         << "VALUES (" << vs.str() << ");";
  cmds_.push_back(cmd.str());
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
std::string SqliteBack::valData(boost::any v) {
  std::stringstream ss;
  if (v.type() == typeid(int)) {
    ss << boost::any_cast<int>(v);
  } else if (v.type() == typeid(float)) {
    ss << boost::any_cast<float>(v);
  } else if (v.type() == typeid(double)) {
    ss << boost::any_cast<double>(v);
  } else if (v.type() == typeid(std::string)) {
    ss << "\"" << boost::any_cast<std::string>(v) << "\"";
  } else {
    CLOG(LEV_ERROR) << "attempted to record unsupported type in backend "
      << path_;
  }
  return ss.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
void SqliteBack::flush(){
  db_->open();
  for (StrList::iterator it = cmds_.begin(); it != cmds_.end(); it++) {
    try {
    db_->execute(*it);
    } catch (CycIOException err) {
      CLOG(LEV_ERROR) << "backend '" << path_ << "' failed write: "
                      << err.what();
    }
  }
  cmds_.clear();
}

