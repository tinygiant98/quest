void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnUnAcquireItem");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
