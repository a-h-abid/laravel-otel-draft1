<?php

namespace App\Providers;

use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Trace\Sampler\AlwaysOnSampler;
use PlunkettScott\LaravelOpenTelemetry\OtelApplicationServiceProvider;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\SDK\Resource\ResourceInfo;
use OpenTelemetry\SDK\Trace\SamplerInterface;
use OpenTelemetry\SDK\Trace\SpanProcessorInterface;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SemConv\ResourceAttributes;

class OtelServiceProvider extends OtelApplicationServiceProvider
{
    /**
     * Return an implementation of SamplerInterface to use for sampling traces.
     */
    public function sampler(): SamplerInterface
    {
        // Customize the sampler you want to use here.
        //
        // The default sampler is an AlwaysOnSampler, which will sample all
        // traces. You can use the ProbabilitySampler to sample a percentage
        // of traces, or the AlwaysOffSampler to disable sampling.
        //
        // It is recommended to use OpenTelemetry Collector to sample traces
        // and use the AlwaysOnSampler here. See the OpenTelemetry Collector
        // documentation for more information.

        return new AlwaysOnSampler();
    }

    /**
     * Return a ResourceInfo instance to merge with default resource attributes.
     */
    public function resourceInfo(): ResourceInfo
    {
        // Customize the resource attributes you want to use here.
        // The default values below are the minimum required by the spec. You
        // should at least set the service name. See the ResourceAttributes
        // interface for a list of available attributes, or add your own.
        //
        // These attributes will be merged with the default attributes set by
        // the SDK, which include the PHP and OS versions, among other things.

        return ResourceInfo::create(Attributes::create([
            ResourceAttributes::SERVICE_NAME => config('app.name', 'Laravel'),
            ResourceAttributes::DEPLOYMENT_ENVIRONMENT => config('app.env', 'production'),
        ]));
    }

    /**
     * Return an array of additional processors to add to the tracer provider.
     *
     * @return SpanProcessorInterface[]
     */
    public function spanProcessors(): array
    {
        // Customize the span processors you want to use here. The default
        // processor is a SimpleSpanProcessor that exports spans via OTLP
        // to a local collector. You can add additional processors here,
        // such as a BatchSpanProcessor, or a SpanProcessor that exports
        // spans to a different collector.

        return [
            // new SimpleSpanProcessor(
            //     exporter: new SpanExporter(
            //         (new OtlpHttpTransportFactory())
            //             ->create('http://127.0.0.1:4318/v1/traces', 'application/x-protobuf'),
            //     ),
            // ),
        ];
    }
}
