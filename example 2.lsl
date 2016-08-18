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

// Define API Seperator For Parsing String Data
string DIALOG_SEPERATOR = "||";

// Dialog Time-Out Defined In Dialog Menu Creation.
integer DIALOG_TIMEOUT = 30;

// Packed Dialog Command
string packed(string message, list buttons, list returns, integer timeout)
{
    string packed_message = message + DIALOG_SEPERATOR + (string)timeout;
    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++) packed_message += DIALOG_SEPERATOR + llList2String(buttons, i) + DIALOG_SEPERATOR + llList2String(returns, i);
    return packed_message;
}

// Show Dialog, If Name Not Specified Will Show First Menu In List
dialog_show(string name, key id)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_SHOW, name, id);
}

// Reshow Last Dialog
dialog_reshow()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_RESHOW, "", NULL_KEY);
}

// Cancel Dialog Request
dialog_cancel()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_CANCEL, "", NULL_KEY);
    llSleep(1);
}

// Create Dialog
add_menu(key id, string message, list buttons, list returns, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_ADD, packed(message, buttons, returns, timeout), id);
}

// Create TextBox
add_textbox(key id, string message, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_TEXTBOX, message + DIALOG_SEPERATOR + (string)timeout, id);
}

// Create Button Sounds
dialog_sound(string sound, float volume)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_SOUND, sound + DIALOG_SEPERATOR + (string)volume, NULL_KEY);
}

// Clear Dialog API Memory
dialog_clear()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_CLEAR, "", NULL_KEY);
}

default{
    state_entry()
    {
        dialog_clear();
        
        dialog_sound("18cf8177-a388-4c1c-90e7-e5750e83d750", 1.0);
        
        add_menu("MainMenu",

            "Main Menu Dialog Message", // Dialog Messages

            [ "BUTTON_1", "BUTTON_2", "BUTTON_3", "Textbox", "BUTTON_X" ], // Dialog Buttons

            [ "MENU_SubMenu1", "MENU_SubMenu2", "MENU_SubMenu3", "Textbox", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu1",

            "Sub Menu 1 Dialog Message", // Dialog Messages

            [ "SUB_1_1", "SUB_1_2", "SUB_1_3", "MAIN MENU", "SUB_3", "BUTTON_X" ], // Dialog Buttons

            [ "1.1", "1.2", "1.3", "MENU_MainMenu", "MENU_SubMenu3", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu2",

            "Sub Menu 2 Dialog Message", // Dialog Messages

            [ "SUB_2_1", "SUB_2_2", "SUB_2_3", "MAIN MENU", "SUB_1", "BUTTON_X" ], // Dialog Buttons

            [ "2.1", "2.2", "2.3", "MENU_MainMenu", "MENU_SubMenu1", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu3",

            "Sub Menu 3 Dialog Message", // Dialog Messages

            [ "SUB_3_1", "SUB_3_2", "SUB_3_3", "MAIN MENU", "SUB_2", "BUTTON_X" ], // Dialog Buttons

            [ "3.1", "3.2", "3.3", "MENU_MainMenu", "MENU_SubMenu2", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );
        
        llSetText("Touch me to show menu", <1,1,1>, 1);
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == LINK_INTERFACE_NOT_FOUND)
        {
            llSay(0, "Menu name: " + str + " Not Found");
        }
        if(num == LINK_INTERFACE_TIMEOUT)
        {
            llOwnerSay("Menu time-out. Please try again.");
        }
        else if(num == LINK_INTERFACE_CANCELLED)
        {
            llSay(0, "Dialog Cancelled");
        }
        else if(num == LINK_INTERFACE_RESPONSE)
        {
            llOwnerSay(str);
            if(str == "Textbox")
            {
                // Add Dialog Textbox
                add_textbox(id,
                    
                    "Textbox Demo",
                    
                    DIALOG_TIMEOUT
                );
            }
        }
    }

    touch_start(integer num_detected)
    {
        dialog_show("MainMenu", llDetectedOwner(0));
    }
}