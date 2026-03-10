"""
Generate card game sound effects as WAV files using only Python stdlib.
"""
import wave
import struct
import math
import os

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')


def write_wav(filename, frames, sample_rate=SAMPLE_RATE):
    path = os.path.join(OUTPUT_DIR, filename)
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(frames)
    size = os.path.getsize(path)
    print(f"  Written: {filename} ({size} bytes)")


def make_frames(duration, freq_fn, amp_fn, sample_rate=SAMPLE_RATE):
    """Generate PCM frames from frequency and amplitude functions of time t (0..1)."""
    n = int(sample_rate * duration)
    frames = bytearray()
    phase = 0.0
    for i in range(n):
        t = i / n
        freq = freq_fn(t)
        amp = amp_fn(t)
        # Advance phase
        phase += 2 * math.pi * freq / sample_rate
        sample = int(amp * 32767 * math.sin(phase))
        sample = max(-32767, min(32767, sample))
        frames += struct.pack('<h', sample)
    return bytes(frames)


def sine_frames(duration, freq, amp=0.6, attack=0.01, release=0.1, sample_rate=SAMPLE_RATE):
    """Simple sine tone with attack/release envelope."""
    n = int(sample_rate * duration)
    frames = bytearray()
    for i in range(n):
        t = i / n
        # Envelope
        env = 1.0
        if t < attack:
            env = t / attack
        elif t > 1.0 - release:
            env = (1.0 - t) / release
        sample = int(amp * env * 32767 * math.sin(2 * math.pi * freq * i / sample_rate))
        sample = max(-32767, min(32767, sample))
        frames += struct.pack('<h', sample)
    return bytes(frames)


def mix(*frame_lists):
    """Mix multiple frame byte sequences by averaging."""
    n = max(len(f) for f in frame_lists) // 2
    result = bytearray(n * 2)
    for frames in frame_lists:
        count = len(frames) // 2
        for i in range(count):
            val = struct.unpack_from('<h', frames, i * 2)[0]
            existing = struct.unpack_from('<h', result, i * 2)[0]
            mixed = max(-32767, min(32767, existing + val // len(frame_lists)))
            struct.pack_into('<h', result, i * 2, mixed)
    return bytes(result)


def concat(*frame_lists):
    return b''.join(frame_lists)


def silence(duration, sample_rate=SAMPLE_RATE):
    return bytes(int(sample_rate * duration) * 2)


# ── deal.wav ──────────────────────────────────────────────────────────────────
# Soft "whoosh" + brief high tick — like a card sliding across felt
def make_deal():
    # Descending tone sweep (500→250 Hz) with noise character
    duration = 0.18
    n = int(SAMPLE_RATE * duration)
    frames = bytearray()
    for i in range(n):
        t = i / n
        freq = 500 - 250 * t          # sweep down
        env = (1 - t) * (1 - t)       # fast decay
        # Add slight noise by mixing two close frequencies
        s1 = math.sin(2 * math.pi * freq * i / SAMPLE_RATE)
        s2 = math.sin(2 * math.pi * (freq * 1.03) * i / SAMPLE_RATE)
        sample = int(0.45 * env * 32767 * (s1 + s2) / 2)
        sample = max(-32767, min(32767, sample))
        frames += struct.pack('<h', sample)
    write_wav('deal.wav', bytes(frames))


# ── move.wav ──────────────────────────────────────────────────────────────────
# Short soft "tick" — a card placed on a pile
def make_move():
    tick = sine_frames(0.04, 900, amp=0.5, attack=0.002, release=0.8)
    soft = sine_frames(0.06, 450, amp=0.25, attack=0.003, release=0.5)
    n = min(len(tick), len(soft)) // 2
    frames = bytearray()
    for i in range(n):
        a = struct.unpack_from('<h', tick, i * 2)[0]
        b = struct.unpack_from('<h', soft, i * 2)[0]
        v = max(-32767, min(32767, (a + b) // 2))
        frames += struct.pack('<h', v)
    # Pad to match longer
    if len(soft) > len(tick):
        frames += soft[len(tick):]
    write_wav('move.wav', bytes(frames))


# ── sequence_complete.wav ─────────────────────────────────────────────────────
# 4-note ascending chime: C5 E5 G5 C6
def make_sequence_complete():
    notes = [523.25, 659.25, 783.99, 1046.50]  # C5, E5, G5, C6
    parts = []
    for freq in notes:
        parts.append(sine_frames(0.18, freq, amp=0.55, attack=0.01, release=0.4))
        parts.append(silence(0.04))
    write_wav('sequence_complete.wav', concat(*parts))


# ── win.wav ───────────────────────────────────────────────────────────────────
# Victory fanfare: C5-E5-G5-C6 quick arpeggio then held chord
def make_win():
    # Quick ascending arpeggio
    arp_notes = [523.25, 659.25, 783.99, 1046.50]
    parts = []
    for freq in arp_notes:
        parts.append(sine_frames(0.12, freq, amp=0.5, attack=0.01, release=0.3))
        parts.append(silence(0.02))
    # Held triumphant chord (C5 + E5 + G5)
    chord = mix(
        sine_frames(0.8, 523.25, amp=0.4, attack=0.02, release=0.3),
        sine_frames(0.8, 659.25, amp=0.4, attack=0.02, release=0.3),
        sine_frames(0.8, 783.99, amp=0.4, attack=0.02, release=0.3),
    )
    parts.append(chord)
    write_wav('win.wav', concat(*parts))


if __name__ == '__main__':
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("Generating sound effects...")
    make_deal()
    make_move()
    make_sequence_complete()
    make_win()
    print("Done.")
