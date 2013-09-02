#ifndef CYCLUS_CYCLOPTS_CBC_SOLVER_H_
#define CYCLUS_CYCLOPTS_CBC_SOLVER_H_

#include <utility>

// coin includes
#include "CoinModel.hpp"
#include "CbcModel.hpp"

#include "function.h"
#include "variable.h"

typedef CbcModel CoinCbcModel;

namespace cyclus {
namespace cyclopts {
/// the coin branch-and-cut solver, see https://projects.coin-or.org/Cbc.
class CBCSolver : public Solver {
 public:
  /// Solve an Mixed-Integer Program.
  /// @param variables A container of variables. The solution is preserved in
  /// the value() member.
  /// @param obj A pointer to the objective function.
  /// @param constraints A container of pointers to the problem's constraints.
  virtual void Solve(std::vector<cyclus::cyclopts::VariablePtr>& variables, 
                     cyclus::cyclopts::ObjFuncPtr obj, 
                     std::vector<cyclus::cyclopts::ConstraintPtr>& constraints);

 private:
  /// the model builder
  CoinModel builder_;

  /// get coin-specific bound for a constraint
  std::pair<double, double> ConstraintBounds(cyclus::cyclopts::ConstraintPtr c);

  /// set variable/objective function values
  void SetUpVariablesAndObj(
      std::vector<cyclus::cyclopts::VariablePtr>& variables, 
      cyclus::cyclopts::ObjFuncPtr obj);

  /// set up constraints
  void SetUpConstraints(
      std::vector<cyclus::cyclopts::ConstraintPtr>& constraints);

  /// set the objective direction
  double ObjDirection(cyclus::cyclopts::ObjFuncPtr obj);

  /// solve the model
  void SolveModel(CbcModel& model);

  /// populate the solution in the variable vector
  void PopulateSolution(CbcModel& model,
                        std::vector<cyclus::cyclopts::VariablePtr>& variables);

  /// print variables info
  void PrintVariables(int n_const);

  /// print objective function info
  void PrintObjFunction(int n_vars);

  /// print constraint info
  void PrintConstraints(int n_const, int n_vars);

  /// prints each other printing function
  void Print(int n_const, int n_vars);
};

} // namespace cyclopts
} // namespace cyclus

#endif
