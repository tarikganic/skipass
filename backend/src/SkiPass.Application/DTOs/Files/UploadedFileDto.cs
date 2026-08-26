namespace SkiPass.Application.DTOs.Files;

/// <summary>Rezultat uspjesnog uploada datoteke.</summary>
public class UploadedFileDto
{
    /// <summary>Relativna putanja koja se sprema u bazu i koristi za prikaz na klijentu.</summary>
    public string Url { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public long SizeBytes { get; set; }
}
