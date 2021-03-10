void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnPlaceableUsed");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}

