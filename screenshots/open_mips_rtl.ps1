Start-Sleep -Seconds 2

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Diagnostics;

public class RTLMips {
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
        Thread.Sleep(400);
        ShowWindow(hwnd, 3);
        Thread.Sleep(500);
        IntPtr fg = GetForegroundWindow();
        uint dummy;
        uint fgTid = GetWindowThreadProcessId(fg, out dummy);
        uint myTid = GetCurrentThreadId();
        AttachThreadInput(myTid, fgTid, true);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(myTid, fgTid, false);
        Thread.Sleep(1000);
        // Alt+T then navigate to Netlist Viewers
        keybd_event(0x12, 0, 0, IntPtr.Zero);
        keybd_event(0x54, 0, 0, IntPtr.Zero);
        keybd_event(0x54, 0, 1, IntPtr.Zero);
        keybd_event(0x12, 0, 1, IntPtr.Zero);
        Thread.Sleep(700);
        // Try 5 Down (one less than the FA test)
        for (int i = 0; i < 5; i++) {
            keybd_event(0x28, 0, 0, IntPtr.Zero);
            keybd_event(0x28, 0, 1, IntPtr.Zero);
            Thread.Sleep(130);
        }
        Thread.Sleep(400);
        keybd_event(0x27, 0, 0, IntPtr.Zero); // Right
        keybd_event(0x27, 0, 1, IntPtr.Zero);
        Thread.Sleep(500);
        keybd_event(0x0D, 0, 0, IntPtr.Zero); // Enter
        keybd_event(0x0D, 0, 1, IntPtr.Zero);
        Thread.Sleep(2000);
        // Screenshot of what opened
        System.IO.File.WriteAllText("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\mips_rtl_status.txt", "keys_sent");
    }
}
"@

$hwnd = (Get-Process -Id 45680).MainWindowHandle
[RTLMips]::Run($hwnd)
