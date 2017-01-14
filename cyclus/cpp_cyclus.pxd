"""C++ header wrapper for specific parts of cyclus."""
from libc.stdint cimport uint64_t
from libcpp.map cimport map
from libcpp.set cimport set
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from libcpp.string cimport string as std_string
from libcpp cimport bool as cpp_bool
from libcpp.typeinfo cimport type_info
from libcpp.memory cimport shared_ptr

from . cimport cpp_jsoncpp
from .cpp_typesystem cimport DbTypes
from .cpp_stringstream cimport stringstream


cdef extern from "<functional>" namespace "std":

    cdef cppclass function[T]:
        function()
        function(T)


cdef extern from "cyclus.h" namespace "boost::spirit":

    cdef cppclass hold_any:
        hold_any() except +
        hold_any(const char*) except +
        hold_any assign[T](T) except +
        T cast[T]() except +
        const type_info& type() except +

cdef extern from "cyclus.h" namespace "boost::uuids":

    cdef cppclass uuid:
        unsigned char data[16]


cdef extern from "version.h" namespace "cyclus::version":

    const char* describe() except +
    const char* core() except +
    const char* boost() except +
    const char* sqlite3() except +
    const char* hdf5() except +
    const char* xml2() except +
    const char* xmlpp() except +
    const char* coincbc() except +
    const char* coinclp() except +


cdef extern from "cyclus.h" namespace "cyclus":

    cdef cppclass Datum:
        ctypedef pair[const char*, hold_any] Entry
        ctypedef vector[Entry] Vals
        ctypedef vector[int] Shape
        ctypedef vector[Shape] Shapes
        ctypedef vector[std_string] Fields

        Datum* AddVal(const char*, hold_any) except +
        Datum* AddVal(const char*, hold_any, vector[int]*) except +
        Datum* AddVal(std_string, hold_any) except +
        Datum* AddVal(std_string, hold_any, vector[int]*) except +
        void Record() except +
        std_string title() except +
        vector[Entry] vals() except +
        vector[vector[int]] shapes() except +
        vector[std_string] fields() except +


cdef extern from "rec_backend.h" namespace "cyclus":

    ctypedef vector[Datum*] DatumList

    cdef cppclass RecBackend:
        void Notify(DatumList) except +
        std_string Name() except +
        void Flush() except +
        void Close() except +


cdef extern from "cyclus.h" namespace "cyclus":

    ctypedef vector[hold_any] QueryRow

    cdef enum CmpOpCode:
        LT
        GT
        LE
        GE
        EQ
        NE

    cdef cppclass Blob:
        Blob() except +
        Blob(std_string) except +
        const std_string str() except +

    cdef cppclass Cond:
        Cond() except +
        Cond(std_string, std_string, hold_any) except +

        std_string field
        std_string op
        CmpOpCode opcode
        hold_any val

    cdef cppclass QueryResult:
        QueryResult() except +

        void Reset() except +
        T GetVal[T](std_string) except +
        T GetVal[T](std_string, int) except +

        vector[std_string] fields
        vector[DbTypes] types
        vector[QueryRow] rows

    cdef cppclass QueryableBackend:
        QueryResult Query(std_string, vector[Cond]*) except +
        map[std_string, DbTypes] ColumnTypes(std_string) except +
        set[std_string] Tables() except +

    cdef cppclass FullBackend(QueryableBackend, RecBackend):
        FullBackend() except +

    cdef cppclass Recorder:
        Recorder() except +
        Recorder(cpp_bool) except +

        unsigned int dump_count() except +
        void set_dump_count(unsigned int) except +
        cpp_bool inject_sim_id() except +
        void inject_sim_id(cpp_bool) except +
        uuid sim_id() except +
        Datum* NewDatum(std_string) except +
        void RegisterBackend(RecBackend*) except +
        void Flush() except +
        void Close() except +


cdef extern from "sqlite_back.h" namespace "cyclus":

    cdef cppclass SqliteBack(FullBackend):
        SqliteBack(std_string) except +


cdef extern from "hdf5_back.h" namespace "cyclus":

    cdef cppclass Hdf5Back(FullBackend):
        Hdf5Back(std_string) except +


cdef extern from "dynamic_module.h" namespace "cyclus":

    cdef cppclass AgentSpec:
        AgentSpec() except +
        #AgentSpec(InfileTree* t);
        AgentSpec(std_string, std_string, std_string, std_string) except +
        AgentSpec(std_string) except +
        std_string Sanitize() except +
        std_string LibPath() except +
        std_string str() except +
        std_string path() except +
        std_string lib() except +
        std_string agent() except +
        std_string alias() except +

cdef extern from "env.h" namespace "cyclus":

    cdef cppclass Env:
        @staticmethod
        std_string PathBase(std_string) except +
        @staticmethod
        const std_string GetInstallPath() except +
        @staticmethod
        const std_string GetBuildPath() except +
        @staticmethod
        std_string GetEnv(std_string) except +
        @staticmethod
        const std_string nuc_data() except +
        @staticmethod
        const std_string rng_schema() except +
        @staticmethod
        const std_string rng_schema(cpp_bool) except +
        @staticmethod
        const vector[std_string] cyclus_path() except +
        @staticmethod
        const cpp_bool allow_milps() except +
        @staticmethod
        const std_string EnvDelimiter() except +
        @staticmethod
        const std_string PathDelimiter() except +
        @staticmethod
        const void SetNucDataPath() except +
        @staticmethod
        const void SetNucDataPath(std_string) except +
        @staticmethod
        std_string FindModule(std_string) except +

cdef extern from "logger.h" namespace "cyclus":

    cdef enum LogLevel:
        LEV_ERROR
        LEV_WARN
        LEV_INFO1
        LEV_INFO2
        LEV_INFO3
        LEV_INFO4
        LEV_INFO5
        LEV_DEBUG1
        LEV_DEBUG2
        LEV_DEBUG3
        LEV_DEBUG4
        LEV_DEBUG5

    cdef cppclass Logger:
        Logger() except +
        @staticmethod
        LogLevel& ReportLevel() except +
        @staticmethod
        void SetReportLevel(LogLevel) except +
        @staticmethod
        cpp_bool& NoAgent() except +
        @staticmethod
        void SetNoAgent(cpp_bool) except +
        @staticmethod
        cpp_bool& NoMem() except +
        @staticmethod
        void SetNoMem(cpp_bool) except +
        @staticmethod
        LogLevel ToLogLevel(std_string) except +
        @staticmethod
        std_string ToString(LogLevel) except +


cdef extern from "error.h" namespace "cyclus":

    cdef unsigned int warn_limit
    cdef cpp_bool warn_as_error


cdef extern from "pyhooks.h" namespace "cyclus":

    cdef void PyInitHooks() except +


cdef extern from "pyhooks.h" namespace "cyclus::toolkit":

    cdef std_string PyToJson(std_string) except +
    cdef std_string JsonToPy(std_string) except +


cdef extern from "xml_file_loader.h" namespace "cyclus":

    cdef void LoadStringstreamFromFile(stringstream&, std_string)
    cdef std_string LoadStringFromFile(std_string)

    cdef cppclass XMLFileLoader:
        XMLFileLoader(Recorder*, QueryableBackend*, std_string) except +
        XMLFileLoader(Recorder*, QueryableBackend*, std_string,
                      const std_string) except +
        void LoadSim() except +


cdef extern from "xml_flat_loader.h" namespace "cyclus":

    cdef cppclass XMLFlatLoader(XMLFileLoader):
        XMLFlatLoader(Recorder*, QueryableBackend*, std_string) except +
        XMLFlatLoader(Recorder*, QueryableBackend*, std_string,
                      const std_string) except +


cdef extern from "xml_parser.h" namespace "cyclus":

    cdef cppclass XMLParser:
        XMLParser() except +
        void Init(const stringstream) except +
        void Init(const std_string) except +


cdef extern from "infile_tree.h" namespace "cyclus":

    cdef cppclass InfileTree:
        InfileTree(XMLParser&) except +

    T OptionalQuery[T](InfileTree*, std_string, T) except +


cdef extern from "timer.h" namespace "cyclus":

    cdef cppclass Timer:
        Timer() except +
        void RunSim() except +


cdef extern from "sim_init.h" namespace "cyclus":

    cdef cppclass SimInit:
        SimInit() except +
        void Init(Recorder*, QueryableBackend*) except +
        Timer* timer() except +
        Context* context() except +


cdef extern from "toolkit/infile_converters.h" namespace "cyclus::toolkit":

    cdef std_string JsonToXml(std_string) except +
    cdef std_string XmlToJson(std_string) except +
    cdef std_string PyToXml(std_string) except +
    cdef std_string XmlToPy(std_string) except +


cdef extern from "db_init.h" namespace "cyclus":

    cdef cppclass Agent

    cdef cppclass DbInit:
        DbInit(Agent*) except +
        DbInit(Agent*, cpp_bool) except +
        Datum* NewDatum(std_string) except +


cdef extern from "resource.h" namespace "cyclus":

    ctypedef std_string ResourceType

    cdef cppclass Resource:
        ctypedef shared_ptr[Resource] Ptr
        Resource()
        const int obj_id()
        const int state_id()
        void BumpStateId()
        int qual_id()
        const ResourceType type()
        shared_ptr[Resource] Clone()
        void Record(Context*)
        std_string units()
        double quantity()
        shared_ptr[Resource] ExtractRes(double)



cdef extern from "request.h" namespace "cyclus":

    cdef cppclass Trader
    cdef cppclass RequestPortfolio[T]

    cdef cppclass Request[T]:
        ctypedef function[double(shared_ptr[T])] cost_function_t
        @staticmethod
        Request[T]* Create(shared_ptr[T], Trader*, shared_ptr[RequestPortfolio[T]],
                           std_string, double, bool)
        @staticmethod
        Request[T]* Create(shared_ptr[T], Trader*, shared_ptr[RequestPortfolio[T]],
                           std_string, double, bool, cost_function_t)
        @staticmethod
        Request[T]* Create(shared_ptr[T], Trader*, std_string, double, bool)
        @staticmethod
        Request[T]* Create(shared_ptr[T], Trader*, std_string, double, bool,
                           cost_function_t)
        shared_ptr[T] target()
        Trader* requester()
        double preference()
        shared_ptr[RequestPortfolio[T]] portfolio()
        bool exclusive()
        cost_function_t cost_function()


cdef extern from "bid.h" namespace "cyclus":

    cdef cppclass Trader
    cdef cppclass BidPortfolio[T]

    cdef cppclass Bid[T]:
        @staticmethod
        Bid[T]* Create(Request[T], shared_ptr[T], Trader*, bool)
        @staticmethod
        Bid[T]* Create(Request[T], shared_ptr[T], Trader*, bool, double)
        @staticmethod
        Bid[T]* Create(Request[T], shared_ptr[T], Trader*,
                       shared_ptr[BidPortfolio[T]], bool)
        @staticmethod
        Bid[T]* Create(Request[T], shared_ptr[T], Trader*,
                       shared_ptr[BidPortfolio[T]], bool, double)
        Request[T]* request()
        shared_ptr[T] offer()
        Trader* bidder()
        shared_ptr[BidPortfolio[T]] portfolio()
        bool exclusive()
        double preference()


cdef extern from "exchange_context.h" namespace "cyclus":

    cdef cppclass PrefMap[T]:
        ctypedef map[Request[T]*, map[Bid[T]*, double]] type


cdef extern from "agent.h" namespace "cyclus":

    cdef cppclass Material
    cdef cppclass Product
    ctypedef map[std_string, vector[Resource.Ptr]] Inventories

    cdef cppclass Agent:
        Agent(Context*) except +
        std_string version() except +
        Agent* Clone() except +
        void InfileToDb(InfileTree*, DbInit) except +
        void InitFrom(QueryableBackend*) except +
        void InitInv(Inventories&) except +
        Inventories SnapshotInv() except +
        std_string PrintChildren() except +
        vector[std_string] GetTreePrintOuts(Agent*)
        bool InFamilyTree(Agent*)
        bool AncestorOf(Agent*)
        bool DecendentOf(Agent*)
        void Build(Agent*)
        void EnterNotify()
        void BuildNotify(Agent*)
        void DecomNotify(Agent*)
        void Decommission()
        void AdjustMatlPrefs(PrefMap[Material].type&)
        void AdjustProductPrefs(PrefMap[Product].type&)
        std_string schema()
        annotations()
        cpp_jsoncpp.Value annotations() except +
        const std_string prototype(std_string)
        void prototype(std_string)
        const int id()
        std_string spec()
        void spec(std_string)
        const std_string kind()
        Context* context()
        std_string str()
        Agent* parent()
        const int parent_id()
        const int enter_time()
        void lifetime(int)
        const int lifetime()
        const int exit_time()
        const set[Agent*]& children()


cdef extern from "composition.h" namespace "cyclus":

    ctypedef Nuc
    ctypedef map[Nuc, double] CompMap

    cdef cppclass Composition:
        ctypedef shared_ptr[Composition] Ptr
        @staticmethod
        shared_ptr[Composition] CreateFromAtom(CompMap)
        @staticmethod
        shared_ptr[Composition] CreateFromMass(CompMap)
        int id()
        const CompMap& atom()
        const CompMap& mass()
        shared_ptr[Composition] Decay(int)
        shared_ptr[Composition] Decay(int, uint64_t)
        void Record(Context*)


cdef extern from "material.h" namespace "cyclus":

    cdef cppclass Material(Resource):
        ctypedef shared_ptr[Material] Ptr
        const ResourceType kType
        @staticmethod
        shared_ptr[Material] Create(Agent*, double, Composition.Ptr)
        @staticmethod
        shared_ptr[Material] CreateUntracked(double, Composition.Ptr)
        shared_ptr[Material] ExtractQty(double)
        shared_ptr[Material] ExtractComp(double, Composition.Ptr)
        shared_ptr[Material] ExtractComp(double, Composition.Ptr, double)
        void Absorb(shared_ptr[Material])
        void Transmute(Composition.Ptr)
        void Decay(int)
        int prev_decay_time()
        double DecayHeat()
        Composition.Ptr comp()


cdef extern from "product.h" namespace "cyclus":

    cdef cppclass Product(Resource):
        ctypedef shared_ptr[Product] Ptr
        const ResourceType kType
        @staticmethod
        shared_ptr[Product] Create(Agent*, double, std_string)
        @staticmethod
        shared_ptr[Product] CreateUntracked(double, std_string)
        const std::string& quality()
        shared_ptr[Product] Extract(double)
        void Absorb(shared_ptr[Product])

cdef extern from "dynamic_module.h" namespace "cyclus":

    cdef cppclass DynamicModule:
        DynamicModule() except +
        @staticmethod
        Agent* Make(Context*, AgentSpec) except +
        cpp_bool Exists(AgentSpec) except +
        void CloseAll() except +
        std_string path() except +


cdef extern from "context.h" namespace "cyclus":

    cdef cppclass Context:
        Context(Timer*, Recorder*) except +
        void DelAgent(Agent*) except +
        uuid sim_id() except +


cdef extern from "discovery.h" namespace "cyclus":

    cdef set[std_string] DiscoverSpecs(std_string, std_string) except +
    cdef set[std_string] DiscoverSpecsInCyclusPath() except +
    cdef cpp_jsoncpp.Value DiscoverMetadataInCyclusPath() except +

