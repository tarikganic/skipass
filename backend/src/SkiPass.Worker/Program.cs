using SkiPass.Worker;
using SkiPass.Worker.Services;

DotEnvLoader.Load();

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddSingleton<ISmtpEmailSender, SmtpEmailSender>();
builder.Services.AddHostedService<EmailConsumerService>();

var host = builder.Build();
host.Run();
