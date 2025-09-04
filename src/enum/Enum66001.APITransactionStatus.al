enum 66001 "API Transaction Status"
{
    Extensible = true;

    value(0; "To be Processed")
    {
    }
    value(100; Failed)
    {
    }
    value(200; Processed)
    {
    }
    value(300; "Closed Manually")
    {
    }
    value(400; "Skip Processing")
    {
    }
}
