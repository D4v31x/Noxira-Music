/*
 * Noxira audio analysis engine - public C ABI.
 *
 * This header is the contract shared by the native engine, the JNI bridge
 * (Kotlin playback tap) and Dart FFI (frame delivery). It has no dependency on
 * Android, JNI or Dart, so the DSP can also be built and tested on a host.
 *
 * Layout notes
 * ------------
 * NoxiraAudioFrame is a plain, naturally aligned struct. Its byte offsets are
 * part of the ABI (Dart reads it through offsets) and are pinned by
 * static_asserts in the engine sources.
 */
#ifndef NOXIRA_AUDIO_H_
#define NOXIRA_AUDIO_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__GNUC__)
#define NOXIRA_API __attribute__((visibility("default")))
#else
#define NOXIRA_API
#endif

#define NOXIRA_ABI_VERSION 3

#define NOXIRA_MAX_BANDS 128
#define NOXIRA_MAX_SPECTRUM 1024
#define NOXIRA_MAX_WAVEFORM 512
#define NOXIRA_REGION_COUNT 7
#define NOXIRA_REGION_EDGE_COUNT 8
#define NOXIRA_MAX_SOURCES 4
#define NOXIRA_VISUALIZER_BINS 2048

/* Analysis / playback state reported in every frame. */
typedef enum NoxiraState {
  NOXIRA_STATE_INACTIVE = 0,    /* analysis not running */
  NOXIRA_STATE_WAITING = 1,     /* running, no PCM source attached yet */
  NOXIRA_STATE_PLAYING = 2,
  NOXIRA_STATE_PAUSED = 3,
  NOXIRA_STATE_BUFFERING = 4,
  NOXIRA_STATE_ENDED = 5,       /* playback completed / stopped */
  NOXIRA_STATE_UNSUPPORTED = 6  /* set by the Dart layer (non-Android) */
} NoxiraState;

/* Bits of NoxiraAudioFrame.flags. Event bits are true for one frame only. */
typedef enum NoxiraFrameFlags {
  NOXIRA_FLAG_ONSET = 1 << 0,
  NOXIRA_FLAG_BEAT = 1 << 1,
  NOXIRA_FLAG_KICK = 1 << 2,
  NOXIRA_FLAG_SNARE = 1 << 3,
  NOXIRA_FLAG_HIHAT = 1 << 4,
  NOXIRA_FLAG_SILENT = 1 << 5   /* input below the noise floor */
} NoxiraFrameFlags;

/* PCM encodings accepted by noxira_engine_push_pcm. */
typedef enum NoxiraPcmEncoding {
  NOXIRA_PCM_S16 = 1,
  NOXIRA_PCM_U8 = 2,
  NOXIRA_PCM_S24 = 3,  /* packed 3 bytes, little endian */
  NOXIRA_PCM_S32 = 4,
  NOXIRA_PCM_F32 = 5
} NoxiraPcmEncoding;

/*
 * Engine configuration. Initialise with noxira_config_default() and then
 * override fields. Out-of-range values are clamped.
 */
typedef struct NoxiraConfig {
  int32_t struct_size;
  int32_t fft_size;          /* 1024, 2048 or 4096 */
  int32_t band_count;        /* 32, 64 or 128 */
  int32_t analysis_rate_hz;  /* frames per second, 10..120 */
  int32_t stereo_bands;      /* non-zero: also analyse left/right bands */
  int32_t spectrum_bins;     /* exported spectrum size, <= NOXIRA_MAX_SPECTRUM */
  int32_t waveform_size;     /* exported waveform size, <= NOXIRA_MAX_WAVEFORM */
  int32_t visualizer_spectrum; /* export capture-scaled, full-resolution Hann magnitudes */
  float min_hz;              /* lowest band edge, >= 10 */
  float max_hz;              /* highest band edge (clamped below Nyquist) */
  float region_edges_hz[NOXIRA_REGION_EDGE_COUNT]; /* ascending, 7 regions */
  float attack_ms;           /* bar smoothing, rising */
  float release_ms;          /* bar smoothing, falling */
  float peak_hold_ms;
  float peak_decay_per_sec;  /* peak marker fall speed, normalised units/s */
  float noise_floor_db;      /* band levels below this (dBFS) are silence */
  float dynamic_range_db;    /* dB below the reference mapped to 0 */
  float min_reference_db;    /* lowest normalisation reference (dBFS) */
  float normalization_release_db_per_sec; /* reference fall speed */
  float sensitivity_tilt_db_per_octave;   /* extra gain per octave above 1 kHz */
  float band_sensitivity_db[NOXIRA_MAX_BANDS]; /* extra per-band gain (dB) */
  float onset_sensitivity;   /* 0..1, higher detects more onsets */
  float latency_compensation_ms; /* delay applied to the analysed audio */
  float contrast;            /* power curve on band/region levels, >1 pushes
                                mid levels down (1 = linear), 0.5..4 */
  float global_reference_mix;/* 0..1: weight of the loudest-band reference vs
                                each band's own recent peak (higher = bands
                                stay in proportion to each other) */
  float level_floor;         /* 0..0.9: normalised levels below this read 0 and
                                the rest is stretched (applied before contrast) */
  float normalization_attack_ms; /* how fast the reference rises to louder
                                content; 0 = follow peaks instantly */
} NoxiraConfig;

/*
 * One analysis result. All floats are IEEE-754 single precision.
 *
 * Normalised values are in [0, 1] unless stated otherwise. Arrays hold
 * `band_count` / `spectrum_count` / `waveform_count` valid entries; the rest
 * is zero. Time-based values (smoothing, decay, peak hold) are independent of
 * the analysis rate.
 */
typedef struct NoxiraAudioFrame {
  int64_t timestamp_us;     /* analysed audio time since the last discontinuity */
  int64_t sequence;         /* increases by 1 per published frame */
  int32_t struct_size;
  int32_t abi_version;
  int32_t state;            /* NoxiraState */
  int32_t sample_rate;      /* Hz of the analysed source, 0 when unknown */
  int32_t source_channels;  /* channel count of the analysed source */
  int32_t fft_size;
  int32_t band_count;
  int32_t spectrum_count;
  int32_t waveform_count;
  int32_t discontinuity_count; /* +1 on seek / track change / flush */
  int32_t flags;            /* NoxiraFrameFlags */
  int32_t visualizer_spectrum_count;

  /* ---- scalar features (offset 64) ---- */
  float rms;                /* linear RMS (both channels) of the latest ~21 ms, 0..~1 FS */
  float peak;               /* largest absolute sample of that window, 0..~1 FS */
  float peak_hold;          /* peak with hold and decay, 0..~1 FS */
  float energy;             /* normalised, smoothed overall loudness */
  float centroid_hz;        /* spectral centroid in Hz, 0 when silent */
  float centroid;           /* centroid on a log 20 Hz..20 kHz scale, 0..1 */
  float flux;               /* normalised spectral flux, 0..1 */
  float zero_crossing_rate; /* sign changes per sample, 0..1 (0.5 = noise) */
  float transient;          /* transient strength, 0..1 */
  float onset_strength;     /* strength of the onset in this frame, else 0 */
  float beat_confidence;    /* 0..1 */
  float bpm;                /* tempo estimate, 0 when unknown */
  float kick;               /* kick-like activity (decaying), 0..1 */
  float snare;              /* snare-like activity, 0..1 */
  float hihat;              /* hi-hat-like activity, 0..1 */
  float percussion;         /* general percussive activity, 0..1 */
  float bass_activity;      /* sustained low-frequency activity, 0..1 */
  float stereo_width;       /* side / (mid + side), 0 mono .. 1 wide */
  float stereo_correlation; /* -1 out of phase .. 1 identical */
  float stereo_balance;     /* -1 left .. 1 right */
  float rms_left;
  float rms_right;
  float peak_left;
  float peak_right;
  float scalar_reserved[8];

  /* ---- frequency regions (offset 192) ---- */
  float regions[NOXIRA_REGION_EDGE_COUNT];      /* sub-bass .. high; [7] unused */
  float region_peaks[NOXIRA_REGION_EDGE_COUNT];

  /* ---- arrays ---- */
  float bands[NOXIRA_MAX_BANDS];        /* combined, log spaced, normalised */
  float bands_left[NOXIRA_MAX_BANDS];   /* equal to bands unless stereo_bands */
  float bands_right[NOXIRA_MAX_BANDS];
  float band_peaks[NOXIRA_MAX_BANDS];   /* peak-hold markers */
  float spectrum[NOXIRA_MAX_SPECTRUM];  /* linear-frequency, normalised dB */
  float waveform_left[NOXIRA_MAX_WAVEFORM];  /* -1..1 */
  float waveform_right[NOXIRA_MAX_WAVEFORM];
  /* Floating-point Hann spectrum in the visualizer's capture amplitude scale.
   * Intended for the calibrated consumer, not dBFS measurements.
   * Linear frequency bins at k * sample_rate / fft_size Hz.
   * Zero unless config.visualizer_spectrum is enabled. */
  float visualizer_spectrum[NOXIRA_VISUALIZER_BINS];
} NoxiraAudioFrame;

/* Runtime counters for profiling and diagnostics. */
typedef struct NoxiraStats {
  int64_t frames_published;
  int64_t push_calls;
  int64_t pushed_frames;
  int64_t ring_overruns;     /* analysis fell behind and skipped audio */
  int32_t active_sources;
  int32_t running;
  float avg_process_us;      /* mean DSP time per frame */
  float max_process_us;
  float avg_push_us;         /* mean cost of one PCM push on the audio thread */
  float max_push_us;
  float cpu_percent;         /* analysis thread CPU / wall time since start */
  float reserved[3];
} NoxiraStats;

/* Called from the analysis thread after each published frame. Must not block. */
typedef void (*NoxiraFrameCallback)(int64_t sequence);

/* ---- configuration ---- */
NOXIRA_API int32_t noxira_abi_version(void);
NOXIRA_API int32_t noxira_frame_size(void);
NOXIRA_API int32_t noxira_config_size(void);
NOXIRA_API void noxira_config_default(NoxiraConfig* out);

/* ---- lifecycle (all idempotent, thread-safe) ---- */
NOXIRA_API int32_t noxira_engine_start(const NoxiraConfig* config);
NOXIRA_API int32_t noxira_engine_update_config(const NoxiraConfig* config);
NOXIRA_API void noxira_engine_stop(void);
NOXIRA_API void noxira_engine_shutdown(void);
NOXIRA_API int32_t noxira_engine_is_running(void);

/* ---- playback state (from Dart) ---- */
NOXIRA_API void noxira_engine_set_playback_state(int32_t state);

/* ---- frame delivery (single reader) ---- */
/* Returns the newest unread frame, or NULL. The pointer stays valid until
 * the next call. */
NOXIRA_API const NoxiraAudioFrame* noxira_engine_acquire_frame(void);
NOXIRA_API void noxira_engine_set_frame_callback(NoxiraFrameCallback callback);
NOXIRA_API void noxira_engine_get_stats(NoxiraStats* out);

/* ---- PCM sources (used by the JNI tap; also exposed for tests) ---- */
/* Returns a source id >= 0, or -1 when all slots are in use. */
NOXIRA_API int32_t noxira_engine_acquire_source(void);
NOXIRA_API void noxira_engine_release_source(int32_t source);
NOXIRA_API void noxira_engine_configure_source(int32_t source, int32_t sample_rate,
                                               int32_t channels);
NOXIRA_API void noxira_engine_flush_source(int32_t source);
NOXIRA_API void noxira_engine_end_source(int32_t source);
/* AudioSink timestamps anchor analysis to audible audio, not queued PCM. */
NOXIRA_API void noxira_engine_update_clock(int32_t source, int64_t queued_end_us,
                                           int64_t audible_us, float speed);
/* Never blocks or allocates. Returns the number of frames consumed. */
NOXIRA_API int32_t noxira_engine_push_pcm(int32_t source, const void* data,
                                          int32_t frame_count, int32_t encoding);

#ifdef __cplusplus
}
#endif

#endif /* NOXIRA_AUDIO_H_ */
