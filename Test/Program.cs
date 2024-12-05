using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

public class RhythmGame : Form
{
    private Timer gameTimer;
    private List<Note> notes;
    private int score = 0;
    private int missed = 0;

    private int laneWidth = 80;
    private int noteSpeed = 5;

    public RhythmGame()
    {
        this.DoubleBuffered = true;
        this.ClientSize = new Size(400, 600);
        this.Text = "Rhythm Game";

        notes = new List<Note>();
        gameTimer = new Timer
        {
            Interval = 16 // ~60 FPS
        };
        gameTimer.Tick += UpdateGame;
        gameTimer.Start();

        this.KeyDown += HandleKeyPress;
    }

    private void UpdateGame(object sender, EventArgs e)
    {
        // Move notes down
        foreach (var note in notes)
        {
            note.Y += noteSpeed;
        }

        // Remove missed notes
        notes.RemoveAll(note =>
        {
            if (note.Y > this.ClientSize.Height)
            {
                missed++;
                return true;
            }
            return false;
        });

        // Spawn new notes periodically
        if (new Random().Next(0, 20) == 0) // Random spawn
        {
            notes.Add(new Note
            {
                Lane = new Random().Next(0, 4),
                Y = -50
            });
        }

        this.Invalidate(); // Redraw
    }

    private void HandleKeyPress(object sender, KeyEventArgs e)
    {
        int lane = -1;

        switch (e.KeyCode)
        {
            case Keys.A: lane = 0; break; // Leftmost lane
            case Keys.S: lane = 1; break;
            case Keys.D: lane = 2; break;
            case Keys.F: lane = 3; break; // Rightmost lane
        }

        if (lane != -1)
        {
            for (int i = 0; i < notes.Count; i++)
            {
                if (notes[i].Lane == lane && Math.Abs(notes[i].Y - (this.ClientSize.Height - 100)) < 30)
                {
                    notes.RemoveAt(i);
                    score++;
                    break;
                }
            }
        }
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        Graphics g = e.Graphics;
        g.Clear(Color.Black);

        // Draw lanes
        for (int i = 0; i < 4; i++)
        {
            g.FillRectangle(Brushes.Gray, i * laneWidth, 0, laneWidth, this.ClientSize.Height);
        }

        // Draw notes
        foreach (var note in notes)
        {
            g.FillRectangle(Brushes.Red, note.Lane * laneWidth + 10, note.Y, laneWidth - 20, 30);
        }

        // Draw hit line
        g.FillRectangle(Brushes.White, 0, this.ClientSize.Height - 100, this.ClientSize.Width, 5);

        // Draw score
        g.DrawString($"Score: {score} | Missed: {missed}", new Font("Arial", 16), Brushes.White, 10, 10);
    }

    public static void Main()
    {
        Application.Run(new RhythmGame());
    }
}

public class Note
{
    public int Lane { get; set; } // Lane index (0-3)
    public int Y { get; set; }    // Y position of the note
}
