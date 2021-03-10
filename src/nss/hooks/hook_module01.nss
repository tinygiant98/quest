
void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnAcquireItem");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
