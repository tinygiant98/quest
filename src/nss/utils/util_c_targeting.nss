/// ----------------------------------------------------------------------------
/// @file   util_c_targeting.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration settings for util_i_targeting.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                          Targeting Mode Script Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to run scripts associated with targeting hooks.
/// @param sScript The script assigned to the current targeting hook.
/// @param oSelf The PC object assigned to the current targeting event.
void RunTargetingHookScript(string sScript, object oSelf = OBJECT_SELF)
{
    SetLocalInt(oSelf, "TARGETING_COMPLETE", TRUE);
    ExecuteScript(sScript, oSelf);
    DeleteLocalInt(oSelf, "TARGETING_COMPLETE");
}
