using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using KubeClient;
using KubeClient.Extensions.KubeConfig;
using KubeClient.Models;
using KubeClient.ResourceClients;
using Microsoft.Extensions.Logging;

namespace Kubectl {
    public abstract class KubeCmdlet : AsyncCmdlet {
        protected ILogger Logger;
        protected ILoggerFactory LoggerFactory;

        protected Dictionary<(string kind, string apiVersion), Type> ModelTypes { get; } =
            ModelMetadata.KubeObject.BuildKindToTypeLookup(typeof(KubeObjectV1).Assembly);

        protected Dictionary<(string kind, string apiVersion), Type> ListModelTypes { get; } =
            ModelMetadata.KubeObject.BuildKindToListTypeLookup(typeof(KubeObjectV1).Assembly);

        protected override async Task BeginProcessingAsync(CancellationToken cancellationToken) {
            await base.BeginProcessingAsync(cancellationToken); ;
            LoggerFactory = new LoggerFactory();
            LoggerFactory.AddProvider(new CmdletLoggerProvider(this));
            // var logFile = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "..", "logs", "PSKubectl-{Date}.log");
            // WriteVerbose($"Logging to {logFile}");
            // LoggerFactory.AddFile(logFile, LogLevel.Trace);
            Logger = LoggerFactory.CreateLogger("KubeCmdlet");
        }

        protected override void Dispose(bool disposing) {
            base.Dispose(disposing);
        }
    }
}
