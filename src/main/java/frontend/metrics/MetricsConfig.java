package frontend.metrics;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;

@Component
public class MetricsConfig {

    private final AtomicInteger activeRequests = new AtomicInteger(0);
    private final Counter spamPredictionsCounter;
    private final Timer predictionLatency;

    public MetricsConfig(MeterRegistry registry) {
        this.spamPredictionsCounter = Counter.builder("app.sms.spam_predictions_total")
                .description("Total number of spam predictions")
                .tag("service", "frontend")
                .register(registry);

        Gauge.builder("app.requests.active", activeRequests, AtomicInteger::get)
                .description("Number of active requests being processed")
                .tag("service", "frontend")
                .register(registry);

        this.predictionLatency = Timer.builder("app.prediction.latency")
                .description("Latency of SMS prediction in milliseconds")
                .tag("service", "frontend")
                .publishPercentiles(0.5, 0.95) // optional percentiles
                .register(registry);
    }

    public void incrementSpamCounter() {
        spamPredictionsCounter.increment();
    }

    public void requestStarted() {
        activeRequests.incrementAndGet();
    }

    public void requestEnded() {
        activeRequests.decrementAndGet();
    }

    public void recordPredictionLatency(long millis) {
        predictionLatency.record(millis, java.util.concurrent.TimeUnit.MILLISECONDS);
    }
}
