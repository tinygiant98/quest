void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnCreatureSpawn");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
