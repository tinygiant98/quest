void main()
{
    SetLocalString(GetModule(), "CURRENT_EVENT", "OnPlaceableClose");
    ExecuteScript("hook_nwn", OBJECT_SELF);
}

