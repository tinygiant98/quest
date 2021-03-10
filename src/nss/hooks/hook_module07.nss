void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnModuleLoad");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}