from flask import Flask
app = Flask(__name__)

# @app.route("/")
# def hello():
#     return "Hello from Flask CI/CD!"
@app.route("/")
def hello():
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Flask CI/CD App</title>
        <style>
            body {
                background: linear-gradient(to right, #6a11cb, #2575fc);
                color: #ffffff;
                font-family: 'Arial', sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                flex-direction: column;
            }
            h1 {
                font-size: 3em;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                margin-bottom: 20px;
            }
            p {
                font-size: 1.5em;
                background: rgba(0,0,0,0.2);
                padding: 10px 20px;
                border-radius: 10px;
            }
            .footer {
                position: absolute;
                bottom: 20px;
                font-size: 0.9em;
                opacity: 0.8;
            }
        </style>
    </head>
    <body>
        <h1>✨ Welcome to My Flask CI/CD App ✨</h1>
        <p>Hello from Flask CI/CD! Your hardened pipeline is working beautifully.</p>
        <div class="footer">Powered by Kubernetes & GitHub Actions, Danielle Felix</div>
    </body>
    </html>
    """


@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
