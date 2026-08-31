Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public struct INPUT {
    public uint type;
    public INPUTUNION union;
}
[StructLayout(LayoutKind.Explicit)]
public struct INPUTUNION {
    [FieldOffset(0)] public MOUSEINPUT mi;
    [FieldOffset(0)] public KEYBDINPUT ki;
}
public struct MOUSEINPUT {
    public int dx, dy, mouseData, dwFlags, time;
    public IntPtr dwExtraInfo;
}
public struct KEYBDINPUT {
    public ushort wVk, wScan;
    public uint dwFlags;
    public uint time;
    public IntPtr dwExtraInfo;
}

public class InputSender {
    [DllImport("user32.dll")] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    
    public const uint KEYEVENTF_KEYDOWN = 0;
    public const uint KEYEVENTF_KEYUP = 2;
    public const uint INPUT_KEYBOARD = 1;
    public const ushort VK_MENU = 0x12;  // Alt
    public const ushort VK_T = 0x54;
    public const ushort VK_F10 = 0x79;
    
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(100);
        AttachThreadInput(myT, fgT, false);
    }
    
    public static bool IsForeground(IntPtr hWnd) {
        return GetForegroundWindow() == hWnd;
    }
    
    public static void SendAltT() {
        INPUT[] inputs = new INPUT[4];
        // Alt down
        inputs[0].type = INPUT_KEYBOARD;
        inputs[0].union.ki.wVk = VK_MENU;
        inputs[0].union.ki.dwFlags = KEYEVENTF_KEYDOWN;
        // T down
        inputs[1].type = INPUT_KEYBOARD;
        inputs[1].union.ki.wVk = VK_T;
        inputs[1].union.ki.dwFlags = KEYEVENTF_KEYDOWN;
        // T up
        inputs[2].type = INPUT_KEYBOARD;
        inputs[2].union.ki.wVk = VK_T;
        inputs[2].union.ki.dwFlags = KEYEVENTF_KEYUP;
        // Alt up
        inputs[3].type = INPUT_KEYBOARD;
        inputs[3].union.ki.wVk = VK_MENU;
        inputs[3].union.ki.dwFlags = KEYEVENTF_KEYUP;
        SendInput(4, inputs, Marshal.SizeOf(typeof(INPUT)));
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$proc = Get-Process -Id 49136
[InputSender]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 500

$isFg = [InputSender]::IsForeground($proc.MainWindowHandle)
"Focus obtained: $isFg" | Out-File "C:\Users\USER\Documents\MIPS_Project\focus_debug.txt"

if ($isFg) {
    [InputSender]::SendAltT()
    Start-Sleep -Milliseconds 1000
    
    [int]$w = 1920; [int]$h = 1080
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    $g.Dispose()
    $bmp.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_altT2.png")
    $bmp.Dispose()
    "Saved screenshot" | Out-File "C:\Users\USER\Documents\MIPS_Project\focus_debug.txt" -Append
} else {
    "Focus NOT obtained - cannot send keys" | Out-File "C:\Users\USER\Documents\MIPS_Project\focus_debug.txt" -Append
}
