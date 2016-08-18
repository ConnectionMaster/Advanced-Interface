// Add Menus To Interface API
integer LINK_INTERFACE_ADD = 0x3E8;

// Cancel Dialog Request
integer LINK_INTERFACE_CANCEL = 0x7D0;

// Cancel Button Is Triggered.
integer LINK_INTERFACE_CANCELLED = 0xBB8; // Message sent from LINK_INTERFACE_CANCEL to link message to be used in other scripts.

// Clear Dialog Request
integer LINK_INTERFACE_CLEAR = 0xFA0;

// Display Dialog Interface
integer LINK_INTERFACE_DIALOG = 0x1388;

// Dialog Not Found
integer LINK_INTERFACE_NOT_FOUND = 0x1770;

// Reshow Last Dialog Displayed
integer LINK_INTERFACE_RESHOW = 0x1B58;

// A Button Is Triggered, Or OK Is Triggered
integer LINK_INTERFACE_RESPONSE = 0x1F40;

// Display Dialog
integer LINK_INTERFACE_SHOW = 0x2328;

// Play Sound When Dialog Button Touched
integer LINK_INTERFACE_SOUND = 0x2710;

// Display Textbox Interface
integer LINK_INTERFACE_TEXTBOX = 0x2AF8;

// No Button Is Hit, Or Ignore Is Hit
integer LINK_INTERFACE_TIMEOUT = 0x2EE0;

// Define A Channel For Listening
integer LISTEN_CHANNEL;

// Define A Channel Handle To Remove LISTEN_CHANNEL
integer LISTEN_HANDLE;

// Define API Seperator For Parsing String Data
string DIALOG_SEPERATOR = "||";

// Message To Be Shown With The Dialog
string DIALOG_MENU_MESSAGE;

// Define A List Containing All The Possible Menu Buttons
list DIALOG_MENU_BUTTONS = [];

// List Of Packed Menus Command, In Order Of DIALOG_MENU_ID_NAMES
list DIALOG_MENU_COMMANDS = []; //DIALOG_MENU_MESSAGE||DIALOG_TIMEOUT||DIALOG_MENU_BUTTONS||DIALOG_MENU_RETURNS

// Define A List Containing All The Possible Menu Names
list DIALOG_MENU_ID_NAMES = [];

// Define A List Containing All The Possible Menu Returns
list DIALOG_MENU_RETURNS = [];

// Sound To Be Played When A Menu Is Shown
string SOUND_UUID = "00000000-0000-0000-0000-000000000000";

// Sound Volume Of The Menu Sound
float SOUND_VOLUME = 1.0;

// Dialog Time-Out Defined In Dialog Menu Creation.
integer DIALOG_TIMEOUT;

// Key Of User Who Attending This Dialog
key AVATAR_UUID;

// Define Tokens For The Prev and Next Operations
string BUTTON_BACK = "◄ Back";
string BUTTON_NEXT = "Next ►";
string BUTTON_OK = "OK ✔";

// Previous Called Menu Index
integer DIALOG_PREVIOUS_INDEX = 0;

// The Maximum Number Of Buttons Interface Supports.
integer DIALOG_MAXIMUM_BUTTONS = 150;

// The Maximum Number Of Buttons That Can Be Displayed In The Dialog At One Time
integer DIALOG_MAX_BUTTONS = 12;

// The Number Of Menu Items Available.
integer DIALOG_ITEMS_COUNT = 0;

// Define Cycle Number To Keep Track Of Which DIALOG_ITEMS_SUBLIST To Display
integer DIALOG_CYCLE_INDEX = 0;

list sort(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}

integer dialog(key id, string message, list buttons)
{
    integer channel = ( -1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) );
    llListenRemove(LISTEN_HANDLE);
    LISTEN_HANDLE = llListen(channel, "", id, "");
    if(DIALOG_ITEMS_COUNT > 0)
        llDialog(id, message, buttons, channel);
    else
        llTextBox(id, message, channel);
    return channel;
}

list cycle(list items, string direction)
{
    list DIALOG_ITEMS_SUBLIST = [];

    if(direction == BUTTON_BACK)
    {
        if(DIALOG_CYCLE_INDEX > 0)
        {
            DIALOG_CYCLE_INDEX--;
        }
    }
    else if(direction == BUTTON_NEXT)
    {
        DIALOG_CYCLE_INDEX++;
    }

    if(DIALOG_CYCLE_INDEX == 0)
    {
        if(DIALOG_ITEMS_COUNT <= DIALOG_MAX_BUTTONS)
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, 0, DIALOG_ITEMS_COUNT - 1);
        }
        else
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, 0, DIALOG_MAX_BUTTONS - 2);

            DIALOG_ITEMS_SUBLIST += [BUTTON_NEXT];
        }
    }
    else
    {
        integer start_index = 0;

        start_index = (DIALOG_MAX_BUTTONS - 1) + ((DIALOG_CYCLE_INDEX - 1) * (DIALOG_MAX_BUTTONS - 2));

        integer items_left = DIALOG_ITEMS_COUNT - start_index;

        if(items_left > DIALOG_MAX_BUTTONS - 2)
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, start_index, start_index + (DIALOG_MAX_BUTTONS - 3));

            DIALOG_ITEMS_SUBLIST = [BUTTON_BACK] + DIALOG_ITEMS_SUBLIST + [BUTTON_NEXT];
        }
        else
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, start_index, DIALOG_ITEMS_COUNT - 1);

            DIALOG_ITEMS_SUBLIST = [BUTTON_BACK] + DIALOG_ITEMS_SUBLIST;
        }
    }
    return sort(DIALOG_ITEMS_SUBLIST);
}

string replace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

response(integer sender_num, integer num, string str, key id)
{
    list data = llParseStringKeepNulls(str, [DIALOG_SEPERATOR], []);
    if(num == LINK_INTERFACE_DIALOG)
    {
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [];

        if(DIALOG_MENU_MESSAGE == "") DIALOG_MENU_MESSAGE = " ";
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;

        integer index;
        integer count = llGetListLength(data);
        if(count > 2)
        {
            DIALOG_ITEMS_COUNT = 0;
            for(index = 2; index<count;index)
            {
                DIALOG_MENU_BUTTONS += [llList2String(data, index++)];
                DIALOG_MENU_RETURNS += [llList2String(data, index++)];
                ++DIALOG_ITEMS_COUNT;
            }
        }
        else
        {
            DIALOG_MENU_BUTTONS = [BUTTON_OK];
            DIALOG_MENU_RETURNS = [];
            DIALOG_ITEMS_COUNT = 1;
        }
		LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
    }
    else if(num == LINK_INTERFACE_TEXTBOX)
    {
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [llList2String(data, 2)];
        DIALOG_ITEMS_COUNT = 0;
        
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;

		LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
    }
    else request(sender_num, num, str, id);
}

clear_dialog()
{
    DIALOG_MENU_BUTTONS = [];
    DIALOG_MENU_RETURNS = [];
    DIALOG_MENU_COMMANDS = [];
    DIALOG_MENU_ID_NAMES = [];
    DIALOG_PREVIOUS_INDEX = 0;
}

add_dialog(string name, string message, list buttons, list returns, integer timeout)
{
    string packed_message = message + DIALOG_SEPERATOR + (string)timeout;

    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++)
    {
        packed_message += DIALOG_SEPERATOR + llList2String(buttons, i) + DIALOG_SEPERATOR + llList2String(returns, i);
    }
    integer index = llListFindList(DIALOG_MENU_ID_NAMES, [name]);
    if(index >= 0)
        DIALOG_MENU_COMMANDS = llListReplaceList(DIALOG_MENU_COMMANDS, [packed_message], index, index);
    else
    {
        DIALOG_MENU_ID_NAMES += [name];
        DIALOG_MENU_COMMANDS += [packed_message];
    }
}

integer show_dialog(string name, key id)
{
    if(llGetListLength(DIALOG_MENU_ID_NAMES) <= 0) return FALSE;

    integer index;
    if(name != "")
    {
        index = llListFindList(DIALOG_MENU_ID_NAMES, [name]);
        if(index < 0) return FALSE;
    }
    else index = DIALOG_PREVIOUS_INDEX;

    DIALOG_PREVIOUS_INDEX = index;

    string packed_message = llList2String(DIALOG_MENU_COMMANDS, index);

    if(SOUND_UUID != NULL_KEY) llTriggerSound(SOUND_UUID, SOUND_VOLUME); 
    llMessageLinked(LINK_THIS, LINK_INTERFACE_DIALOG, packed_message, id);
    return TRUE;
}

request(integer sender_num, integer num, string str, key id)
{
    list data = llParseString2List(str, [DIALOG_SEPERATOR], []);
    if(num == LINK_INTERFACE_RESPONSE)
    {
        if(llGetSubString(str, 0, 4) == "MENU_")
        {
            str = llDeleteSubString(str, 0, 4);
            show_dialog(str, id);
        }
    }
    else if(num == LINK_INTERFACE_CLEAR)
    {
        clear_dialog();
    }
    else if(num == LINK_INTERFACE_ADD)
    {
		integer DIALOG_FREE_MEMORY = ((llGetListLength(data) - 2) / 2);
        if(DIALOG_FREE_MEMORY < DIALOG_MAXIMUM_BUTTONS + 1)
        {
            DIALOG_MENU_MESSAGE = llList2String(data, 0);
            DIALOG_TIMEOUT = llList2Integer(data, 1);
            DIALOG_MENU_BUTTONS = [];
            DIALOG_MENU_RETURNS = [];
            integer index = 2;
            integer count = llGetListLength(data);
            for(index = 2; index < count; index)
            {
                DIALOG_MENU_BUTTONS += [llList2String(data, index++)];
                DIALOG_MENU_RETURNS += [llList2String(data, index++)];
            }
            add_dialog((string)id, DIALOG_MENU_MESSAGE, DIALOG_MENU_BUTTONS, DIALOG_MENU_RETURNS, DIALOG_TIMEOUT);
        }
        else llSay(0, "Too Many Buttons, Try Reduce the Menu Size");
    }
    else if(num == LINK_INTERFACE_SHOW)
    {
        if(!show_dialog(str, id)) llMessageLinked(sender_num, LINK_INTERFACE_NOT_FOUND, str, NULL_KEY);

    }
    else if(num == LINK_INTERFACE_SOUND)
    {
        SOUND_UUID = llList2String(data, 0);
        SOUND_VOLUME = llList2Float(data, 1);
    }
}

default
{
    state_entry()
    {
		llSetTimerEvent(0);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    timer()
    {
        llMessageLinked(LINK_THIS, LINK_INTERFACE_TIMEOUT, "", AVATAR_UUID);
		state default;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
		llOwnerSay("Free Memory = " + (string)llGetFreeMemory());
        if(num == LINK_INTERFACE_RESHOW)
        {
			LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(num == LINK_INTERFACE_CANCEL)
        {
            llMessageLinked(LINK_THIS, LINK_INTERFACE_CANCELLED, "", AVATAR_UUID);
        }
        else
        {
            response(sender_num, num, str, id);
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;

        if(msg == BUTTON_BACK)
        {
			LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, BUTTON_BACK));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(msg == BUTTON_NEXT)
        {
			LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, BUTTON_NEXT));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(msg == " ")
        {
			LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else
        {
			if(DIALOG_ITEMS_COUNT > 0)
			{
				integer index = llListFindList(DIALOG_MENU_BUTTONS, [msg]);
				llMessageLinked(LINK_THIS, LINK_INTERFACE_RESPONSE, llList2String(DIALOG_MENU_RETURNS, index), AVATAR_UUID);
			}
			else
			{
				llMessageLinked(LINK_THIS, LINK_INTERFACE_RESPONSE, msg, AVATAR_UUID);
			}
        }
    }
}