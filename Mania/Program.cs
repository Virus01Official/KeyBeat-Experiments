using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using NAudio.Wave;

using Timer = System.Windows.Forms.Timer;

namespace Rhythm_game
{
    public class RhythmGameForm : Form
    {
        private Timer gameTimer;
        private List<Note> notes;
        private int score;
        private const int TargetLineY = 400;
        private const int NoteSpeed = 5;
        private Random random;
        private IWavePlayer waveOutDevice;  // For audio playback
        private AudioFileReader audioFileReader;  // For reading the MP3 file

        public RhythmGameForm()
        {
            this.Text = "Rhythm Game";
            this.Size = new Size(800, 600);
            this.DoubleBuffered = true;

            gameTimer = new Timer { Interval = 16 }; // ~60 FPS
            gameTimer.Tick += GameTick;
            notes = new List<Note>();
            random = new Random();

            this.KeyDown += OnKeyDown;

            // Initialize and play background music using NAudio
            waveOutDevice = new WaveOutEvent();  // Creates a new wave output device
            audioFileReader = new AudioFileReader("backgroundMusic.mp3");  // Path to your MP3 file
            waveOutDevice.Init(audioFileReader);  // Initializes the audio playback
            waveOutDevice.Play();  // Starts playing the music in the background

            gameTimer.Start();
        }

        private void GameTick(object sender, EventArgs e)
        {
            // Move notes
            foreach (var note in notes)
            {
                note.Y += NoteSpeed;
            }

            // Remove notes that pass the screen
            notes.RemoveAll(note => note.Y > this.ClientSize.Height);

            // Randomly generate new notes
            if (random.NextDouble() < 0.02) // Adjust spawn rate here
            {
                notes.Add(new Note(random.Next(0, 4)));
            }

            // Redraw the screen
            this.Invalidate();
        }

        private void OnKeyDown(object sender, KeyEventArgs e)
        {
            // Check for matching notes at the target line
            var keyMap = new Dictionary<Keys, int>
            {
                { Keys.D, 0 },
                { Keys.F, 1 },
                { Keys.J, 2 },
                { Keys.K, 3 }
            };

            if (keyMap.TryGetValue(e.KeyCode, out int lane))
            {
                var hitNote = notes.FirstOrDefault(note => note.Lane == lane &&
                                                          Math.Abs(note.Y - TargetLineY) < 20);
                if (hitNote != null)
                {
                    notes.Remove(hitNote);
                    score += 100;
                    // Optionally, play a sound or effect when a note is hit
                    // For example, you could add a hit sound:
                    // new SoundPlayer("hitSound.wav").Play();
                }
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            Graphics g = e.Graphics;

            // Draw target line
            g.DrawLine(Pens.Red, 0, TargetLineY, this.ClientSize.Width, TargetLineY);

            // Draw lanes
            for (int i = 0; i < 4; i++)
            {
                int laneX = i * 200;
                g.DrawRectangle(Pens.Gray, laneX + 50, 0, 100, this.ClientSize.Height);
            }

            // Draw notes
            foreach (var note in notes)
            {
                g.FillRectangle(Brushes.Blue, note.Lane * 200 + 50, note.Y, 100, 20);
            }

            // Draw score
            g.DrawString($"Score: {score}", this.Font, Brushes.Black, 10, 10);
        }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.Run(new RhythmGameForm());
        }

        private class Note
        {
            public int Lane { get; }
            public int Y { get; set; }

            public Note(int lane)
            {
                Lane = lane;
                Y = 0;
            }
        }
    }
}
