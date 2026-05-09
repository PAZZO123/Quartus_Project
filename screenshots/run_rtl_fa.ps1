Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;

public class RTLOpener {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, IntPtr dwExtraInfo);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);

    public static void Run(IntPtr hwnd) {
        foreach (var proc in Process.GetProcesses()) {
            try {
                string name = proc.ProcessName.ToLower();
                if ((name.Contains("chrome") || name.Contains("msedge") || name.Contains("firefox") || name.Contains("whatsapp"))
                    && proc.MainWindowHandle != IntPtr.Zero) {
                    ShowWindow(proc.MainWindowHandle, 6);
                }
            } catch {}
        }
        Thread.Sleep(500);
        ShowWindow(hwnd, 3);
        Thread.Sleep(300);
        IntPtr fg = GetForegroundWindow();
        uint dummy;
        uint fgTid = GetWindowThreadProcessId(fg, out dummy);
        uint myTid = GetCurrentThreadId();
        AttachThreadInput(myTid, fgTid, true);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(myTid, fgTid, false);
        Thread.Sleep(800);
        // Alt+T
        keybd_event(0x12, 0, 0, IntPtr.Zero);
        keybd_event(0x54, 0, 0, IntPtr.Zero);
        keybd_event(0x54, 0, 1, IntPtr.Zero);
        keybd_event(0x12, 0, 1, IntPtr.Zero);
        Thread.Sleep(700);
        // 7x Down
        for (int i = 0; i < 7; i++) {
            keybd_event(0x28, 0, 0, IntPtr.Zero);
            keybd_event(0x28, 0, 1, IntPtr.Zero);
            Thread.Sleep(120);
        }
        Thread.Sleep(400);
        // Right
        keybd_event(0x27, 0, 0, IntPtr.Zero);
        keybd_event(0x27, 0, 1, IntPtr.Zero);
        Thread.Sleep(500);
        // Enter
        keybd_event(0x0D, 0, 0, IntPtr.Zero);
        keybd_event(0x0D, 0, 1, IntPtr.Zero);
        Thread.Sleep(10000);
        // Take screenshot
        System.Windows.Forms.Application.DoEvents();
    }
}
"@ -ReferencedAssemblies System.Windows.Forms

$hwnd = (Get-Process -Id 58068).MainWindowHandle
[RTLOpener]::Run($hwnd)

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$s = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($s.Width, $s.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($s.Location, [System.Drawing.Point]::Empty, $s.Size)
$bmp.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_rtl_fa.png")
$g.Dispose()
$bmp.Dispose()
[System.IO.File]::WriteAllText("C:\Users\USER\Documents\MIPS_Project\screenshots\rtl_fa_done.txt", "done")
