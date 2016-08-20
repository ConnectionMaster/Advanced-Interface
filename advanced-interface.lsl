// Add Menus To Interface API
integer link_interface_add = 0x3E8;

// Cancel Dialog Request
integer link_interface_cancel = 0x7D0;

// Cancel Button Is Triggered.
integer link_interface_cancelled = 0xBB8; // Message sent from link_interface_cancel to link message to be used in other scripts.

// Clear Dialog Request
integer link_interface_clear = 0xFA0;

// Display Dialog Interface
integer link_interface_dialog = 0x1388;

// Dialog Not Found
integer link_interface_not_found = 0x1770;

// Reshow Last Dialog Displayed
integer link_interface_reshow = 0x1B58;

// A Button Is Triggered, Or OK Is Triggered
integer link_interface_response = 0x1F40;

// Display Dialog
integer link_interface_show = 0x2328;

// Play Sound When Dialog Button Touched
integer link_interface_sound = 0x2710;

// Display Textbox Interface
integer link_interface_textbox = 0x2AF8;

// No Button Is Hit, Or Ignore Is Hit
integer link_interface_timeout = 0x2EE0;

// Define A Channel For Listening
integer listen_channel;

// Define A Channel Handle To Remove listen_channel
integer listen_handle;

// Define API Seperator For Parsing String Data
string dialog_seperator = "||";

// Message To Be Shown With The Dialog
string dialog_menu_message;

// Define A List Containing All The Possible Menu Buttons
list dialog_menu_buttons = [];

// List Of Packed Menus Command, In Order Of dialog_menu_id_names
list dialog_menu_commands = []; //dialog_menu_message||dialog_timeout||dialog_menu_buttons||dialog_menu_returns

// Define A List Containing All The Possible Menu Names
list dialog_menu_id_names = [];

// Define A List Containing All The Possible Menu Returns
list dialog_menu_returns = [];

// Sound To Be Played When A Menu Is Shown
string sound_uuid = "00000000-0000-0000-0000-000000000000";

// Sound Volume Of The Menu Sound
float sound_volume = 1.0;

// Dialog Time-Out Defined In Dialog Menu Creation.
integer dialog_timeout;

// Key Of User Who Attending This Dialog
key avatar_uuid;

// Define Tokens For The Prev and Next Operations
string button_back = "◄ Back";
string button_next = "Next ►";
string button_ok = "OK ✔";

// Previous Called Menu Index
integer dialog_previous_index = 0;

// The Maximum Number Of Buttons Interface Supports.
integer dialog_maximum_buttons = 150;

// The Maximum Number Of Buttons That Can Be Displayed In The Dialog At One Time
integer dialog_max_buttons = 12;

// The Number Of Menu Items Available.
integer dialog_items_count = 0;

// Define Cycle Number To Keep Track Of Which dialog_items_sublist To Display
integer dialog_cycle_index = 0;

list sort(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}

integer dialog(key id, string message, list buttons)
{
    integer channel = ( -1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) );
    llListenRemove(listen_handle);
    listen_handle = llListen(channel, "", id, "");
    if(dialog_items_count > 0)
        llDialog(id, message, buttons, channel);
    else
        llTextBox(id, message, channel);
    return channel;
}

list cycle(list items, string direction)
{
    list dialog_items_sublist = [];

    if(direction == button_back)
    {
        if(dialog_cycle_index > 0)
        {
            dialog_cycle_index--;
        }
    }
    else if(direction == button_next)
    {
        dialog_cycle_index++;
    }

    if(dialog_cycle_index == 0)
    {
        if(dialog_items_count <= dialog_max_buttons)
        {
            dialog_items_sublist = llList2List(items, 0, dialog_items_count - 1);
        }
        else
        {
            dialog_items_sublist = llList2List(items, 0, dialog_max_buttons - 2);

            dialog_items_sublist += [button_next];
        }
    }
    else
    {
        integer start_index = 0;

        start_index = (dialog_max_buttons - 1) + ((dialog_cycle_index - 1) * (dialog_max_buttons - 2));

        integer items_left = dialog_items_count - start_index;

        if(items_left > dialog_max_buttons - 2)
        {
            dialog_items_sublist = llList2List(items, start_index, start_index + (dialog_max_buttons - 3));

            dialog_items_sublist = [button_back] + dialog_items_sublist + [button_next];
        }
        else
        {
            dialog_items_sublist = llList2List(items, start_index, dialog_items_count - 1);

            dialog_items_sublist = [button_back] + dialog_items_sublist;
        }
    }
    return sort(dialog_items_sublist);
}

string replace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

response(integer sender_num, integer num, string str, key id)
{
    list data = llParseStringKeepNulls(str, [dialog_seperator], []);
    if(num == link_interface_dialog)
    {
        dialog_menu_message = llList2String(data, 0);
        dialog_timeout = llList2Integer(data, 1);
        avatar_uuid = id;
        dialog_menu_buttons = [];
        dialog_menu_returns = [];

        if(dialog_menu_message == "") dialog_menu_message = " ";
        if(dialog_timeout > 7200) dialog_timeout = 7200;

        integer index;
        integer count = llGetListLength(data);
        if(count > 2)
        {
            dialog_items_count = 0;
            for(index = 2; index<count;index)
            {
                dialog_menu_buttons += [llList2String(data, index++)];
                dialog_menu_returns += [llList2String(data, index++)];
                ++dialog_items_count;
            }
        }
        else
        {
            dialog_menu_buttons = [button_ok];
            dialog_menu_returns = [];
            dialog_items_count = 1;
        }
		listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, ""));
    }
    else if(num == link_interface_textbox)
    {
        dialog_menu_message = llList2String(data, 0);
        dialog_timeout = llList2Integer(data, 1);
        avatar_uuid = id;
        dialog_menu_buttons = [];
        dialog_menu_returns = [llList2String(data, 2)];
        dialog_items_count = 0;
        
        if(dialog_timeout > 7200) dialog_timeout = 7200;

		listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, ""));
    }
    else request(sender_num, num, str, id);
}

clear_dialog()
{
    dialog_menu_buttons = [];
    dialog_menu_returns = [];
    dialog_menu_commands = [];
    dialog_menu_id_names = [];
    dialog_previous_index = 0;
}

add_dialog(string name, string message, list buttons, list returns, integer timeout)
{
    string packed_message = message + dialog_seperator + (string)timeout;

    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++)
    {
        packed_message += dialog_seperator + llList2String(buttons, i) + dialog_seperator + llList2String(returns, i);
    }
    integer index = llListFindList(dialog_menu_id_names, [name]);
    if(index >= 0)
        dialog_menu_commands = llListReplaceList(dialog_menu_commands, [packed_message], index, index);
    else
    {
        dialog_menu_id_names += [name];
        dialog_menu_commands += [packed_message];
    }
}

integer show_dialog(string name, key id)
{
    if(llGetListLength(dialog_menu_id_names) <= 0) return FALSE;

    integer index;
    if(name != "")
    {
        index = llListFindList(dialog_menu_id_names, [name]);
        if(index < 0) return FALSE;
    }
    else index = dialog_previous_index;

    dialog_previous_index = index;

    string packed_message = llList2String(dialog_menu_commands, index);

    if(sound_uuid != NULL_KEY) llTriggerSound(sound_uuid, sound_volume); 
    llMessageLinked(LINK_THIS, link_interface_dialog, packed_message, id);
    return TRUE;
}

request(integer sender_num, integer num, string str, key id)
{
    list data = llParseString2List(str, [dialog_seperator], []);
    if(num == link_interface_response)
    {
        if(llGetSubString(str, 0, 4) == "MENU_")
        {
            str = llDeleteSubString(str, 0, 4);
            show_dialog(str, id);
        }
    }
    else if(num == link_interface_clear)
    {
        clear_dialog();
    }
    else if(num == link_interface_add)
    {
		integer dialog_free_memory = ((llGetListLength(data) - 2) / 2);
        if(dialog_free_memory < dialog_maximum_buttons + 1)
        {
            dialog_menu_message = llList2String(data, 0);
            dialog_timeout = llList2Integer(data, 1);
            dialog_menu_buttons = [];
            dialog_menu_returns = [];
            integer index = 2;
            integer count = llGetListLength(data);
            for(index = 2; index < count; index)
            {
                dialog_menu_buttons += [llList2String(data, index++)];
                dialog_menu_returns += [llList2String(data, index++)];
            }
            add_dialog((string)id, dialog_menu_message, dialog_menu_buttons, dialog_menu_returns, dialog_timeout);
        }
        else llSay(0, "Too Many Buttons, Try Reduce the Menu Size");
    }
    else if(num == link_interface_show)
    {
        if(!show_dialog(str, id)) llMessageLinked(sender_num, link_interface_not_found, str, NULL_KEY);

    }
    else if(num == link_interface_sound)
    {
        sound_uuid = llList2String(data, 0);
        sound_volume = llList2Float(data, 1);
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
        llMessageLinked(LINK_THIS, link_interface_timeout, "", avatar_uuid);
		state default;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
		llOwnerSay("Free Memory = " + (string)llGetFreeMemory());
        if(num == link_interface_reshow)
        {
			listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, ""));
            llSetTimerEvent(dialog_timeout);
        }
        else if(num == link_interface_cancel)
        {
            llMessageLinked(LINK_THIS, link_interface_cancelled, "", avatar_uuid);
        }
        else
        {
            response(sender_num, num, str, id);
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if((channel != listen_channel) || (id != avatar_uuid)) return;

        if(msg == button_back)
        {
			listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, button_back));
            llSetTimerEvent(dialog_timeout);
        }
        else if(msg == button_next)
        {
			listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, button_next));
            llSetTimerEvent(dialog_timeout);
        }
        else if(msg == " ")
        {
			listen_channel = dialog(avatar_uuid, dialog_menu_message, cycle(dialog_menu_buttons, ""));
            llSetTimerEvent(dialog_timeout);
        }
        else
        {
			if(dialog_items_count > 0)
			{
				integer index = llListFindList(dialog_menu_buttons, [msg]);
				llMessageLinked(LINK_THIS, link_interface_response, llList2String(dialog_menu_returns, index), avatar_uuid);
			}
			else
			{
				llMessageLinked(LINK_THIS, link_interface_response, msg, avatar_uuid);
			}
        }
    }
}