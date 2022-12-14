#include "RustSystem.h"

#include "spring-rust-plugin.h"
#include "System/Log/ILog.h"
#include "Sim/Units/Unit.h"
#include "Sim/Units/UnitDef.h"

#include "System/EventHandler.h"


RustSystem::RustSystem() :
  CEventClient("[RustSystem]", 23253, false) {
  LOG("Rust system function initialization...");
  LOG("Invoke function: %d", rust_function());

  // autoLinkEvents = true;
	// RegisterLinkedEvents(this);
	eventHandler.AddClient(this);
}


void RustSystem::UnitCreated(const CUnit *unit, const CUnit *builder)
{
  unit_created(unit->id, builder != nullptr ? builder->id : -1);
}

void RustSystem::UnitFinished(const CUnit *unit)
{
  unit_finished(unit->id);
}

void RustSystem::UnitDestroyed(const CUnit *unit, const CUnit *attacker)
{
  unit_destroyed(unit->id, attacker != nullptr ? attacker->id : -1);
}
