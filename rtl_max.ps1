Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public struct INPUT { public uint type; public INPUTUNION u; }
[StructLayout(LayoutKind.Explicit)]
public struct INPUTUNION {
    [FieldOffset(0)] public MOUSEINPUT mi;
    [FieldOffset(0)] public KEYBDINPUT ki;
}
public struct MOUSEINPUT { public int dx,dy,mouseData,dwFlags,time; public IntPtr dwExtraInfo; }
public struct KEYBDINPUT { public ushort wVk,wScan; public uint dwFlags,time; public IntPtr dwExtraInfo; }

public class RTLMax {
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, int e);
    
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(200);
        AttachThreadInput(myT, fgT, false);
    }
    public static bool IsFg(IntPtr h) { return GetForegroundWindow() == h; }
    public static void TypeKey(ushort vk) {
        INPUT[] inp = new INPUT[2];
        inp[0].type=1; inp[0].u.ki.wVk=vk;
        inp[1].type=1; inp[1].u.ki.wVk=vk; inp[1].u.ki.dwFlags=2;
        SendInput(2, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
        Thread.Sleep(100);
    }
    public static void Click(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(100);
        mouse_event(2,(uint)x,(uint)y,0,0); Thread.Sleep(60); mouse_event(4,(uint)x,(uint)y,0,0);
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Find the RTL Viewer window  
$procs = Get-Process | Where-Object { $_.MainWindowTitle -like "*RTL Viewer*" }
$procs | ForEach-Object { "Found: PID=$($_.Id) | $($_.MainWindowTitle)" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Append }

if ($procs.Count -gt 0) {
    $rtlProc = $procs[0]
    [RTLMax]::ForceFront($rtlProc.MainWindowHandle)
    Start-Sleep -Milliseconds 500
    
    # Press Escape to close any open menu
    [RTLMax]::TypeKey(0x1B)
    Start-Sleep -Milliseconds 300
    
    # Press Ctrl+Shift+F to fit schematic to window (if Quartus shortcut works)
    # Or just take screenshot of the current state
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_rtl_max.png")
    $b.Dispose()
    "RTL max screenshot saved" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Append
} else {
    "RTL Viewer window not found" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Append
    # List all windows
    Get-Process | Where-Object { $_.MainWindowTitle -ne "" } | ForEach-Object { "  $($_.MainWindowTitle)" } | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Append
}
