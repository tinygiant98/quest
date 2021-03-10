void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnPlayerChat");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
