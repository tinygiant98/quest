void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnCreatureDeath");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
