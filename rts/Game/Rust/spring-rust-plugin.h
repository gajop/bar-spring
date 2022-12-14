#pragma once


extern "C"
{
	int rust_function();
	int unit_created(int unit, int builder);
	int unit_finished(int unit);
	int unit_destroyed(int unit, int attacker);
}
