void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnCreatureConversation");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}
