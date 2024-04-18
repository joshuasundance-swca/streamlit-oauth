FROM node:latest AS npmbuilder
COPY ./streamlit_oauth/frontend /streamlit_oauth/streamlit_oauth/frontend
WORKDIR /streamlit_oauth/streamlit_oauth/frontend
RUN npm install && npm run build
CMD ["/bin/bash"]

FROM python:3.11-slim-bookworm AS streamlitapp

RUN adduser --uid 1000 --disabled-password --gecos '' appuser
USER 1000

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:$PATH"

WORKDIR /streamlit_oauth

COPY LICENSE /streamlit_oauth/LICENSE
COPY MANIFEST.in /streamlit_oauth/MANIFEST.in
COPY README.md /streamlit_oauth/README.md
COPY setup.py /streamlit_oauth/setup.py

COPY ./streamlit_oauth/ /streamlit_oauth/streamlit_oauth/
COPY --from=npmbuilder /streamlit_oauth/streamlit_oauth/frontend/ /streamlit_oauth/streamlit_oauth/frontend/
#COPY --from=npmbuilder /streamlit_oauth/streamlit_oauth/frontend/build /streamlit_oauth/streamlit_oauth/frontend/build

RUN pip install --user --no-cache-dir .

CMD ["streamlit", "run", "example.py", "--server.port=8501", "--server.address=0.0.0.0"]

FROM streamlitapp AS artifactbuilder
RUN python -m pip install build setuptools wheel
COPY --from=streamlitapp /streamlit_oauth /streamlit_oauth
WORKDIR /streamlit_oauth
COPY generate_artifacts.sh /streamlit_oauth/generate_artifacts.sh
CMD ["/bin/bash", "generate_artifacts.sh"]
