docker run -it --entrypoint /usr/app/rest_server.rb -p 127.0.0.1:4567:4567 --rm --name joe_cli \
  -v ~/.aws/:/root/.aws/ -v ~/.ssh/:/root/.ssh/ \
  -v $PWD/ansible/vars/:/usr/app/ansible/vars/ \
  -e AWS_SSH_PRIVATE_KEY_PATH='/root/.ssh/aws_drupal.pem' \
  joe:latest;
