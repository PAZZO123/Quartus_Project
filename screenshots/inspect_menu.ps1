Start-Sleep -Seconds 1

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

public class MenuInspect {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint id);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, IntPtr e);

    public static void Run(IntPtr hwnd) {
        foreach (var p in Process.GetProcesses()) {
            try {
                string n = p.ProcessName.ToLower();
                if ((n.Contains("chrome") || n.Contains("edge") || n.Contains("winword"))
                    && p.MainWindowHandle != IntPtr.Zero)
                    ShowWindow(p.MainWindowHandle, 6);
            } catch {}
        }
        Thread.Sleep(500);
        ShowWindow(hwnd, 3);
        Thread.Sleep(400);
        IntPtr fg = GetForegroundWindow();
        uint dummy;
        uint fgTid = GetWindowThreadProcessId(fg, out dummy);
        uint myTid = GetCurrentThreadId();
        AttachThreadInput(myTid, fgTid, true);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(myTid, fgTid, false);
        Thread.Sleep(800);
        // Open Tools menu
        keybd_event(0x12, 0, 0, IntPtr.Zero); // Alt
        keybd_event(0x54, 0, 0, IntPtr.Zero); // T
        keybd_event(0x54, 0, 1, IntPtr.Zero);
        keybd_event(0x12, 0, 1, IntPtr.Zero);
        Thread.Sleep(600);
        // Screenshot with menu open
        var s = Screen.PrimaryScreen.Bounds;
        var bmp = new Bitmap(s.Width, s.Height);
        var g = Graphics.FromImage(bmp);
        g.CopyFromScreen(s.Location, Point.Empty, s.Size);
        bmp.Save("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\tools_menu_open.png", ImageFormat.Png);
        g.Dispose(); bmp.Dispose();
        // Now Escape to close menu
        keybd_event(0x1B, 0, 0, IntPtr.Zero);
        keybd_event(0x1B, 0, 1, IntPtr.Zero);
    }
}
"@ -ReferencedAssemblies System.Drawing, System.Windows.Forms

$hwnd = (Get-Process -Id 58068).MainWindowHandle
[MenuInspect]::Run($hwnd)
[System.IO.File]::WriteAllText("C:\Users\USER\Documents\MIPS_Project\screenshots\rtl_fa_done.txt", "inspect_done")
