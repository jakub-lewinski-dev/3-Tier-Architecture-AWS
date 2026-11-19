
import os

import boto3
import psycopg
from flask import Flask, jsonify

app = Flask(__name__)

AWS_REGION = os.getenv("AWS_REGION", "eu-central-1")

rds_client = boto3.client(
    "rds",
    region_name=AWS_REGION
)


def get_database_connection():
    host = os.environ["DB_HOST"]
    port = int(os.getenv("DB_PORT", "5432"))
    username = os.environ["DB_USER"]

    # Generate a temporary IAM authentication token.
    token = rds_client.generate_db_auth_token(
        DBHostname=host,
        Port=port,
        DBUsername=username,
        Region=AWS_REGION
    )

    return psycopg.connect(
        host=host,
        port=port,
        dbname=os.environ["DB_NAME"],
        user=username,
        password=token,
        connect_timeout=3,
        sslmode="verify-full",
        sslrootcert=os.getenv(
            "DB_SSLROOTCERT",
            "/etc/ssl/certs/rds-global-bundle.pem"
        )
    )


@app.get("/")
def index():
    return jsonify({
        "application": "aws-3-tier-portfolio",
        "status": "running"
    })


@app.get("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.get("/db-health")
def db_health():
    try:
        with get_database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()

        return jsonify({"database": "connected"}), 200

    except (psycopg.Error, KeyError, ValueError):
        app.logger.exception("Database health check failed")
        return jsonify({"database": "unavailable"}), 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
