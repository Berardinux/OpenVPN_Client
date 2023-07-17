#!/usr/bin/env python3
import gi
import subprocess

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class MyApplication(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="OpenVPN")

        # Set the border width of the window
        self.set_border_width(10)

        # Create a list box
        listbox = Gtk.ListBox()
        listbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.add(listbox)

        # Set the default size of the window
        self.set_default_size(400, 300)

        # Create a list box row
        row_1 = Gtk.ListBoxRow()
        box_1 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=100)
        row_1.add(box_1)
        listbox.add(row_1)

        # Create a label
        label = Gtk.Label(label="VPN Status:")
        box_1.pack_start(label, False, False, 0)

        # Create a switch button
        self.switch = Gtk.Switch()
        self.switch.connect("notify::active", self.on_switch_toggled)
        box_1.pack_start(self.switch, False, False, 0)

        self.is_vpn_on = False

    def on_switch_toggled(self, switch, gparam):
        if switch.get_active():
            subprocess.run(["pkexec", "roachvpn", "start"])
            self.is_vpn_on = True
        else:
            subprocess.run(["pkexec", "roachvpn", "stop"])
            self.is_vpn_on = False

win = MyApplication()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()

