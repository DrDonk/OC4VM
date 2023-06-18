DefinitionBlock ("", "SSDT", 1, "APPLE ", "Debug", 0x00001000)
{
    /*
     * Many OEM ACPI implementations have a ADBG function which is used for
     * debug logging. In almost all cases, this function calls MDBG, which is
     * supposed to be defined in a ACPI debug SSDT (but is usually missing).
     * This should make ADBG functional.
     */
    Method (MDBG, 1, NotSerialized)
    {
        Debug = Arg0
    }
}