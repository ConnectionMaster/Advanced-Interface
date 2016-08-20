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

// Define API Seperator For Parsing String Data
string dialog_seperator = "||";

// Dialog Time-Out Defined In Dialog Menu Creation.
integer dialog_timeout = 30;

// Dialog Texture Buttons List.
list TEXTURE_BUTTONS = [];

// Dialog Texture Returns List.
list TEXTURE_RETURNS = [];

// Packed Dialog Command
string packed(string message, list buttons, list returns, integer timeout)
{
    string packed_message = message + dialog_seperator + (string)timeout;
    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++) packed_message += dialog_seperator + llList2String(buttons, i) + dialog_seperator + llList2String(returns, i);
    return packed_message;
}

// Show Dialog, If Name Not Specified Will Show First Menu In List
dialog_show(string name, key id)
{
    llMessageLinked(LINK_THIS, link_interface_show, name, id);
}

// Reshow Last Dialog
dialog_reshow()
{
    llMessageLinked(LINK_THIS, link_interface_reshow, "", NULL_KEY);
}

// Cancel Dialog Request
dialog_cancel()
{
    llMessageLinked(LINK_THIS, link_interface_cancel, "", NULL_KEY);
    llSleep(1);
}

// Create Dialog
add_menu(key id, string message, list buttons, list returns, integer timeout)
{
    llMessageLinked(LINK_THIS, link_interface_add, packed(message, buttons, returns, timeout), id);
}

// Create TextBox
add_textbox(key id, string message, integer timeout)
{
    llMessageLinked(LINK_THIS, link_interface_textbox, message + dialog_seperator + (string)timeout, id);
}

// Create Button Sounds
dialog_sound(string sound, float volume)
{
    llMessageLinked(LINK_THIS, link_interface_sound, sound + dialog_seperator + (string)volume, NULL_KEY);
}

// Clear Dialog API Memory
dialog_clear()
{
    llMessageLinked(LINK_THIS, link_interface_clear, "", NULL_KEY);
}

list inventory(integer type)
{
    list inventory = [];
    integer index;
    integer count = llGetInventoryNumber(type);
    string  inventory_name;
    for(index=0; index<count; index++)
    {
        inventory_name = llGetInventoryName(type, index);
        inventory += [inventory_name];
    }
    return inventory;
}

list prefix(string prefix, string message)
{
    list data = llParseStringKeepNulls(message, [dialog_seperator], []);
    list inventory_prefix = [];
    integer index;
    integer count = llGetListLength(data);
    string  prefix_name;
    for(index=0; index<count; index++)
    {
        prefix_name = llList2String(data, index);
        inventory_prefix += [prefix + prefix_name];
    }
    return inventory_prefix;
}

initialize()
{
    TEXTURE_BUTTONS = inventory(INVENTORY_TEXTURE);

    TEXTURE_RETURNS = prefix("TEXTURE_", llDumpList2String(inventory(INVENTORY_TEXTURE), dialog_seperator));

    dialog_clear();
        
    dialog_sound("18cf8177-a388-4c1c-90e7-e5750e83d750", 1.0);
        
    add_menu("MainMenu",

        "Main Menu Dialog Message", // Dialog Messages

        TEXTURE_BUTTONS, // Dialog Buttons

        TEXTURE_RETURNS, // Dialog Returns

        dialog_timeout // Dialog Timeout
    );
}

default
{
    state_entry()
    {
        initialize();
    }

    changed(integer changes)
    {
        if(changes & CHANGED_INVENTORY) initialize();
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == link_interface_response)
        {
            llOwnerSay("link_interface_response:" + str);
            if(llGetSubString(str, 0, 7) == "TEXTURE_")
            {
                llOwnerSay("INVENTORY_TEXTURE:" + str);
                str = llDeleteSubString(str, 0, 7);
                if(llGetInventoryType(str) == INVENTORY_TEXTURE) llSetTexture(str, ALL_SIDES);
            }
        }
    }

    touch_start(integer total_number)
    {
        dialog_show("MainMenu", llDetectedOwner(0));
    }
}