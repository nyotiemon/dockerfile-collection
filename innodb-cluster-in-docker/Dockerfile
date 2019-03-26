FROM python:2
WORKDIR /usr/src/app
COPY looping.py ./
COPY basedb.py ./
RUN pip install PyMySQL gevent cryptography
CMD ["python","./looping.py"]
