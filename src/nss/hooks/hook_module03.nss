
void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnClientEnter");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
