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

default{
    state_entry()
    {
        dialog_clear();
        
        dialog_sound("18cf8177-a388-4c1c-90e7-e5750e83d750", 1.0);
        
        add_menu("MainMenu",

            "Main Menu Dialog Message", // Dialog Messages

            [ "BUTTON_1", "BUTTON_2", "BUTTON_3", "Textbox", "BUTTON_X" ], // Dialog Buttons

            [ "MENU_SubMenu1", "MENU_SubMenu2", "MENU_SubMenu3", "Textbox", "EXIT" ], // Dialog Returns

            dialog_timeout // Dialog Timeout
        );

        add_menu("SubMenu1",

            "Sub Menu 1 Dialog Message", // Dialog Messages

            [ "SUB_1_1", "SUB_1_2", "SUB_1_3", "MAIN MENU", "SUB_3", "BUTTON_X" ], // Dialog Buttons

            [ "1.1", "1.2", "1.3", "MENU_MainMenu", "MENU_SubMenu3", "EXIT" ], // Dialog Returns

            dialog_timeout // Dialog Timeout
        );

        add_menu("SubMenu2",

            "Sub Menu 2 Dialog Message", // Dialog Messages

            [ "SUB_2_1", "SUB_2_2", "SUB_2_3", "MAIN MENU", "SUB_1", "BUTTON_X" ], // Dialog Buttons

            [ "2.1", "2.2", "2.3", "MENU_MainMenu", "MENU_SubMenu1", "EXIT" ], // Dialog Returns

            dialog_timeout // Dialog Timeout
        );

        add_menu("SubMenu3",

            "Sub Menu 3 Dialog Message", // Dialog Messages

            [ "SUB_3_1", "SUB_3_2", "SUB_3_3", "MAIN MENU", "SUB_2", "BUTTON_X" ], // Dialog Buttons

            [ "3.1", "3.2", "3.3", "MENU_MainMenu", "MENU_SubMenu2", "EXIT" ], // Dialog Returns

            dialog_timeout // Dialog Timeout
        );
        
        llSetText("Touch me to show menu", <1,1,1>, 1);
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == link_interface_not_found)
        {
            llSay(0, "Menu name: " + str + " Not Found");
        }
        if(num == link_interface_timeout)
        {
            llOwnerSay("Menu time-out. Please try again.");
        }
        else if(num == link_interface_cancelled)
        {
            llSay(0, "Dialog Cancelled");
        }
        else if(num == link_interface_response)
        {
            llOwnerSay(str);
            if(str == "Textbox")
            {
                // Add Dialog Textbox
                add_textbox(id,
                    
                    "Textbox Demo",
                    
                    dialog_timeout
                );
            }
        }
    }

    touch_start(integer num_detected)
    {
        dialog_show("MainMenu", llDetectedOwner(0));
    }
}