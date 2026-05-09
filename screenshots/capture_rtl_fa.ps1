Start-Sleep -Seconds 1

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

public class CaptureRTL {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint id);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, IntPtr e);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, System.Text.StringBuilder sb, int max);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    public static IntPtr FindRTLWindow() {
        IntPtr found = IntPtr.Zero;
        EnumWindows((h, p) => {
            var sb = new System.Text.StringBuilder(256);
            GetWindowText(h, sb, 256);
            if (sb.ToString().StartsWith("RTL Viewer")) {
                found = h;
                return false;
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static void Run() {
        IntPtr rtlHwnd = FindRTLWindow();
        if (rtlHwnd == IntPtr.Zero) {
            System.IO.File.WriteAllText("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\rtl_fa_status.txt", "RTL window not found");
            return;
        }
        // Bring RTL Viewer to front
        ShowWindow(rtlHwnd, 3);
        Thread.Sleep(300);
        IntPtr fg = GetForegroundWindow();
        uint dummy;
        uint fgTid = GetWindowThreadProcessId(fg, out dummy);
        uint myTid = GetCurrentThreadId();
        AttachThreadInput(myTid, fgTid, true);
        BringWindowToTop(rtlHwnd);
        SetForegroundWindow(rtlHwnd);
        AttachThreadInput(myTid, fgTid, false);
        Thread.Sleep(500);
        // Press Escape to close any open menu
        keybd_event(0x1B, 0, 0, IntPtr.Zero);
        keybd_event(0x1B, 0, 1, IntPtr.Zero);
        Thread.Sleep(400);
        // Press Ctrl+Shift+F for fit to window / zoom to fit
        keybd_event(0x11, 0, 0, IntPtr.Zero); // Ctrl
        keybd_event(0x10, 0, 0, IntPtr.Zero); // Shift
        keybd_event(0x46, 0, 0, IntPtr.Zero); // F
        keybd_event(0x46, 0, 1, IntPtr.Zero);
        keybd_event(0x10, 0, 1, IntPtr.Zero);
        keybd_event(0x11, 0, 1, IntPtr.Zero);
        Thread.Sleep(500);
        // Screenshot
        var s = Screen.PrimaryScreen.Bounds;
        var bmp = new Bitmap(s.Width, s.Height);
        var g = Graphics.FromImage(bmp);
        g.CopyFromScreen(s.Location, Point.Empty, s.Size);
        bmp.Save("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\screen_rtl_fa.png", ImageFormat.Png);
        g.Dispose(); bmp.Dispose();
        System.IO.File.WriteAllText("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\rtl_fa_status.txt", "done:" + rtlHwnd.ToString());
    }
}
"@ -ReferencedAssemblies System.Drawing, System.Windows.Forms

[CaptureRTL]::Run()
[System.IO.File]::WriteAllText("C:\Users\USER\Documents\MIPS_Project\screenshots\rtl_fa_done2.txt", "done")
