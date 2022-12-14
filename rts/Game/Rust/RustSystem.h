#pragma once

#include "System/EventClient.h"

class RustSystem : public CEventClient
{
public:
  RustSystem();

  bool WantsEvent(const std::string &eventName) override
  {
    return (eventName == "UnitCreated") ||
           (eventName == "UnitFinished") ||
           (eventName == "UnitDestroyed");
  }
	bool GetFullRead() const override { return true; }
	int GetReadAllyTeam() const override { return AllAccessTeam; }

  void UnitCreated(const CUnit *unit, const CUnit *builder) override;
  void UnitFinished(const CUnit *unit) override;
  void UnitDestroyed(const CUnit *unit, const CUnit *attacker) override;
};
