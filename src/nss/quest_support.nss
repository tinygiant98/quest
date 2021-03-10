
#include "quest_i_main"

void AssignQuestToPC(object oPC, string sQuestTag)
{
    if (GetIsQuestAssignable(oPC, sQuestTag))
    {
        QuestDebug(HexColorString("Quest " + sQuestTag + " is assignable", COLOR_GREEN_LIGHT));
        AssignQuest(oPC, sQuestTag);
    }
    else
        QuestDebug(HexColorString("Quest " + sQuestTag + " is NOT assignable", COLOR_RED_LIGHT));
}

location _GetRandomLocationAroundObject(object oTarget, float fRadius)
{
    // Get location data
    location lTarget = GetLocation(oTarget);
    vector vTarget = GetPositionFromLocation(lTarget);

    // Randomize the radius
    float fDistance = Random(FloatToInt(fRadius * 10) + 1) / 10.0;

    // Generate a random angle and facing
    float fAngle = IntToFloat(Random(360));
    float fFacing = IntToFloat(Random(360));

    vector vRandom;
    vRandom.x = vTarget.x + (fDistance * cos(fAngle));
    vRandom.y = vTarget.y + (fDistance * sin(fAngle));
    vRandom.z = vRandom.z;

    return Location(GetArea(oTarget), vRandom, fFacing);
}

void ResetGatherQuestArea(object oPC)
{
    string sTag, sTags = "quest_gather_helmet,quest_gather_shield,quest_gather_armor";
    string sResref, sResrefs = "nw_arhe001,nw_ashlw001,nw_aarcl001";
    int i, n, nCount = CountList(sTags);
    object oItem;

    // Clean up the PC
    oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (HasListItem(sTags, GetTag(oItem)))
            DestroyObject(oItem);

        oItem = GetNextItemInInventory(oPC);
    }

    //Clean the area
    object oWP = GetObjectByTag("quest_gather_field");

    for (n = 0; n < nCount; n++)
    {
        i = 0;
        
        sTag = GetListItem(sTags, n);
        oItem = GetNearestObjectByTag(sTag, oWP, i++);
        while (GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            oItem = GetNearestObjectByTag(sTag, oWP, i++);
        }
    }

    //Create new stuff
    for (n = 0; n < nCount; n++)
    {
        i = 0;
        sTag = GetListItem(sTags, n);
        sResref = GetListItem(sResrefs, n);

        while (i++ < 3)
        {
            location l = _GetRandomLocationAroundObject(oWP, 3.0);
            //location l = GetRandomLocation(GetArea(oPC), oWP, 3.0);
            CreateObject(OBJECT_TYPE_ITEM, sResref, l, FALSE, sTag);
        }
    }
}