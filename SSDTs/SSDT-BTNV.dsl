/*
In ACPI, add 4 rename:
- BTNV to XTNV:
Find: 42544E56 02
Replace: 58544E56 02

- _LID to XLID:
Find: 5F4C4944 00
Replace: 584C4944 00

- _PTS to ZPTS(1,N):
Find: 5F505453 01
Replace: 5A505453 01

- _WAK to ZWAK(1,N):
Find: 5F57414B 01
Replace: 5A57414B 01

- _OSI to XOSI:
Find: 5F4F5349
Replace: 584F5349
*/

DefinitionBlock ("", "SSDT", 2, "hack", "BTNV", 0x00000000)
{
    External (_SB_.PCI9.FNOK, IntObj)
    External (_SB_.PCI9.MODE, IntObj)
    External (_SB_.LID0.XLID, MethodObj)  
    External (_SB_.PCI9.FNOK, IntObj)
    External (_SB_.XTNV, MethodObj)  
    External (_SB_.LID0, DeviceObj)
    External (ZPTS, MethodObj)    
    External (ZWAK, MethodObj)   

    Scope (_SB)
    {
        Device (PCI9)
        {
            Name (_ADR, Zero) 
            Name (FNOK, Zero)
            Name (MODE, Zero)
            Name (TPTS, Zero)
            Name (TWAK, Zero)
            Method (_STA, 0, NotSerialized) 
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Method (BTNV, 2, NotSerialized)
        {
            If ((_OSI ("Darwin") && (Arg0 == 0x02)))
            {
                If ((\_SB.PCI9.MODE == One))
                {
                    \_SB.PCI9.FNOK = One
                    \_SB.XTNV (Arg0, Arg1)
                }
                Else
                {
                    If ((\_SB.PCI9.FNOK != One))
                    {
                        \_SB.PCI9.FNOK = One
                    }
                    Else
                    {
                        \_SB.PCI9.FNOK = Zero
                    }

                    \_SB.XTNV (0x03, Arg1)
                }
            }
            Else
            {
                \_SB.XTNV (Arg0, Arg1)
            }
        }
    }

    Scope (_SB.LID0)
    {
        Method (_LID, 0, NotSerialized) 
        {
            If (_OSI ("Darwin"))
            {
                If ((\_SB.PCI9.FNOK == One))
                {
                    Return (Zero)
                }
                Else
                {
                    Return (\_SB.LID0.XLID ())
                }
            }
            Else
            {
                Return (\_SB.LID0.XLID ())
            }
        }
    }

    Method (_PTS, 1, NotSerialized) 
    {
        If (_OSI ("Darwin"))
        {
            \_SB.PCI9.TPTS = Arg0
            If ((\_SB.PCI9.FNOK == One))
            {
                Arg0 = 0x03
            }
        }

        ZPTS (Arg0)
    }

    Method (_WAK, 1, NotSerialized) 
    {
        If (_OSI ("Darwin"))
        {
            \_SB.PCI9.TWAK = Arg0
            If ((\_SB.PCI9.FNOK == One))
            {
                \_SB.PCI9.FNOK = Zero
                Arg0 = 0x03
            }
        }

        Local0 = ZWAK (Arg0)
        Return (Local0)
    }
}

