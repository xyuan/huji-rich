#ifndef HDSIM_3D_HPP
#define HDSIM_3D_HPP 1

#include "computational_cell.hpp"
#include "../../3D/Tessellation/Tessellation3D.hpp"
#include "conserved_3d.hpp"
#include "../common/equation_of_state.hpp"
#include "point_motion_3d.hpp"
#include "time_step_calculator.hpp"
#include "flux_calculator.hpp"
#include "cell_updater.hpp"

class HDSim3D
{
public:

HDSim3D(const Tessellation3D& tess,
	const vector<ComputationalCell>& cells,
	const EquationOfState& eos,
	const PointMotion3D& pm,
	const TimeStepCalculator& tsc,
	const FluxCalculator& fc,
	const CellUpdater& cu);

private:
  const Tessellation3D& tess_;
  const EquationOfState& eos_;
  vector<ComputationalCell> cells_;
  vector<Conserved3D> extensive_;
  const PointMotion3D& pm_;
  const TimeStepCalculator& tsc_;
  const FluxCalculator& fc_;
  const CellUpdater& cu_;
};

#endif // HDSIM_3D_HPP