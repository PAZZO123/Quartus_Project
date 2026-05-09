Start-Sleep -Seconds 1

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;

public class RTLHelper {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int cmd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, IntPtr e);
    [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);

    public static void Run(IntPtr hwnd) {
        // Close browsers and Word
        foreach (var p in Process.GetProcesses()) {
            try {
                string n = p.ProcessName.ToLower();
                if ((n.Contains("chrome") || n.Contains("edge") || n.Contains("winword"))
                    && p.MainWindowHandle != IntPtr.Zero) {
                    ShowWindow(p.MainWindowHandle, 6); // minimize
                }
            } catch {}
        }
        Thread.Sleep(600);
        // Bring Quartus to front
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
        Thread.Sleep(1000);
        // Alt+T to open Tools menu
        keybd_event(0x12, 0, 0, IntPtr.Zero); // Alt down
        keybd_event(0x54, 0, 0, IntPtr.Zero); // T down
        keybd_event(0x54, 0, 1, IntPtr.Zero); // T up
        keybd_event(0x12, 0, 1, IntPtr.Zero); // Alt up
        Thread.Sleep(800);
        // 6x Down (NOT 7 — 7 opens TimeQuest, 6 should be Netlist Viewers)
        for (int i = 0; i < 6; i++) {
            keybd_event(0x28, 0, 0, IntPtr.Zero);
            keybd_event(0x28, 0, 1, IntPtr.Zero);
            Thread.Sleep(130);
        }
        Thread.Sleep(400);
        // Right to expand submenu
        keybd_event(0x27, 0, 0, IntPtr.Zero);
        keybd_event(0x27, 0, 1, IntPtr.Zero);
        Thread.Sleep(600);
        // Enter to select RTL Viewer
        keybd_event(0x0D, 0, 0, IntPtr.Zero);
        keybd_event(0x0D, 0, 1, IntPtr.Zero);
        Thread.Sleep(10000);
    }
}
"@

$hwnd = (Get-Process -Id 58068).MainWindowHandle
[RTLHelper]::Run($hwnd)

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$s = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($s.Width, $s.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($s.Location, [System.Drawing.Point]::Empty, $s.Size)
$bmp.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_rtl_fa.png")
$g.Dispose(); $bmp.Dispose()
[System.IO.File]::WriteAllText("C:\Users\USER\Documents\MIPS_Project\screenshots\rtl_fa_done.txt", "done")
