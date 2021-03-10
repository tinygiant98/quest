void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnTriggerEnter");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
