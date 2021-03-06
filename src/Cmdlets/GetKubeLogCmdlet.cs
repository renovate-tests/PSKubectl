using System;
using System.Collections.Generic;
using System.IO;
using System.Reactive.Linq;
using System.Management.Automation;
using KubeClient;
using KubeClient.Models;
using KubeClient.ResourceClients;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;

namespace Kubectl.Cmdlets {
    [Cmdlet(VerbsCommon.Get, "KubeLog")]
    [OutputType(new[] { typeof(string) })]
    public class GetKubeLogCmdlet : KubeApiCmdlet {
        [Parameter(ValueFromPipelineByPropertyName = true)]
        [Alias("Ns")]
        public string Namespace { get; set; }

        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string Name { get; set; }

        [Parameter(Position = 1)]
        public string Container { get; set; }

        [Parameter()]
        public SwitchParameter Follow { get; set; }

        [Parameter()]
        public int? LimitBytes { get; set; }

        [Parameter()]
        public int? Tail { get; set; }

        protected override async Task ProcessRecordAsync(CancellationToken cancellationToken) {
            base.BeginProcessing();
            if (Follow) {
                IObservable<string> logs = client.PodsV1().StreamLogs(
                    kubeNamespace: Namespace,
                    name: Name,
                    containerName: Container,
                    limitBytes: LimitBytes,
                    tailLines: Tail
                );
                await logs.ObserveOn(SynchronizationContext.Current).ForEachAsync(WriteObject, cancellationToken);
            } else {
                string logs = await client.PodsV1().Logs(
                    kubeNamespace: Namespace,
                    name: Name,
                    containerName: Container,
                    limitBytes: LimitBytes,
                    tailLines: Tail,
                    cancellationToken: cancellationToken
                );
                WriteObject(logs);
            }
        }
    }
}
