/// is_blocked(hitbox, opponent)

// Returns true if the opponent's state blocks the attack
switch (argument0.blocked_by) {

	// This attack can't be blocked at all, so return false
	case Blocked_By.Unblockable: 
		return false;
		break;
		
	// Returns true if the opponent is blocking while standing
	case Blocked_By.CrouchedBlock: 
		return argument1.state == Character_State.BlockingCrouching;
		break;
		
	// Return true when the opponent is blocking while standing
	case Blocked_By.StandingBlock:
		return argument1.state == Character_State.BlockingStanding;
		break;
		
	// Return true if the opponent is blocking at all
	case Blocked_By.AnyBlock:
	default:
		return argument1.state == Character_State.BlockingStanding
				or argument1.state == Character_State.BlockingCrouching;
}