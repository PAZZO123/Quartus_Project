Start-Sleep -Seconds 1

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

public class TclRTL {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint id);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, int x, int y, uint d, IntPtr e);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, IntPtr e);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr hi, int x, int y, int cx, int cy, uint f);

    static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    const uint SWP_NOSIZE = 0x0001, SWP_NOMOVE = 0x0002, SWP_SHOWWINDOW = 0x0040;

    public static void Run(IntPtr hwnd) {
        foreach (var p in Process.GetProcesses()) {
            try {
                string n = p.ProcessName.ToLower();
                if ((n.Contains("chrome") || n.Contains("edge") || n.Contains("winword"))
                    && p.MainWindowHandle != IntPtr.Zero)
                    ShowWindow(p.MainWindowHandle, 6);
            } catch {}
        }
        Thread.Sleep(400);
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
        // Click in Tcl console input at y=643 (1920x1080 maximized Quartus)
        SetCursorPos(400, 643);
        Thread.Sleep(200);
        mouse_event(0x0002, 0, 0, 0, IntPtr.Zero); // click down
        Thread.Sleep(80);
        mouse_event(0x0004, 0, 0, 0, IntPtr.Zero); // click up
        Thread.Sleep(400);
        // Type the command
        string cmd = "execute_module -tool rtlview";
        foreach (char c in cmd) {
            bool shift = char.IsUpper(c) || "!@#$%^&*()_+{}|:\"<>?".IndexOf(c) >= 0;
            byte vk = (byte)System.Windows.Forms.Keys.LShiftKey;
            if (shift) keybd_event(vk, 0, 0, IntPtr.Zero);
            // Simple approach: use SendMessage/PostMessage equivalent via keybd_event
            var keys = System.Windows.Forms.SendKeys.SendWait;
            System.Windows.Forms.SendKeys.SendWait(c.ToString());
            if (shift) keybd_event(vk, 0, 1, IntPtr.Zero);
            Thread.Sleep(30);
        }
        Thread.Sleep(300);
        // Press Enter
        keybd_event(0x0D, 0, 0, IntPtr.Zero);
        keybd_event(0x0D, 0, 1, IntPtr.Zero);
        Thread.Sleep(12000); // Wait for RTL Viewer to open
        // Screenshot
        var s = Screen.PrimaryScreen.Bounds;
        var bmp = new Bitmap(s.Width, s.Height);
        var g = Graphics.FromImage(bmp);
        g.CopyFromScreen(s.Location, Point.Empty, s.Size);
        bmp.Save("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\mips_rtl_tcl.png", ImageFormat.Png);
        g.Dispose(); bmp.Dispose();
        System.IO.File.WriteAllText("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\mips_rtl_tcl_done.txt", "done");
    }
}
"@ -ReferencedAssemblies System.Drawing, System.Windows.Forms

$hwnd = (Get-Process -Id 45680).MainWindowHandle
[TclRTL]::Run($hwnd)
