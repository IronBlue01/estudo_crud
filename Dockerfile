FROM php:8.1-fpm

# set your user name, ex: user=bernardo
ARG user=root
ARG uid=1000

#RUN chmod -R 777 /usr/local/etc/php/
#RUN sed -i  's/^;*\(max_execution_time\).*/\1 = 100/' /usr/local/etc/php/php.ini-development
#RUN sed -i  's/^;*\(max_execution_time\).*/\1 = 100/' /usr/local/etc/php/php.ini-production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    unzip \
    git \
    git-crypt \
    curl \
    wget \
    libaio1 \
    libonig-dev \
    libpng-dev \
    zlib1g-dev \
    vim \
    zsh \
    xclip

RUN apt-get update && apt-get -y install rsync

RUN apt-get update -qq && apt-get -y install -qq libpq-dev

# Clear cache
RUN apt-get autoremove --yes
RUN rm -rf /var/lib/{apt,dpkg,cache,log}
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git config --system --add safe.directory '*'

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd sockets
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
# RUN useradd -G www-data,root -u $uid -d /home $user
# RUN mkdir -p /home/.composer && \
#     chown -R $user:$user /home 

RUN mkdir -p /home
RUN touch /home/.zshrc


# Add crontab file in the cron directory
ADD .docker/nginx/crontab /etc/cron.d/hello-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/hello-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

#Install Cron
RUN apt-get update
RUN apt-get -y install cron

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log

###########################################################################
# Oh My ZSH!
###########################################################################

USER root

ARG SHELL_OH_MY_ZSH=true

ARG SHELL_OH_MY_ZSH_AUTOSUGESTIONS=true
ARG SHELL_OH_MY_ZSH_ALIASES=true

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc" && \
    sed -i -r 's/^plugins=\(.*?\)$/plugins=(laravel5)/' /home/.zshrc && \
    echo '\n\
bindkey "^[OB" down-line-or-search\n\
bindkey "^[OC" forward-char\n\
bindkey "^[OD" backward-char\n\
bindkey "^[OF" end-of-line\n\
bindkey "^[OH" beginning-of-line\n\
bindkey "^[[1~" beginning-of-line\n\
bindkey "^[[3~" delete-char\n\
bindkey "^[[4~" end-of-line\n\
bindkey "^[[5~" up-line-or-history\n\
bindkey "^[[6~" down-line-or-history\n\
bindkey "^?" backward-delete-char\n' >> /home/.zshrc && \
  if [ ${SHELL_OH_MY_ZSH_AUTOSUGESTIONS} = true ]; then \
    sh -c "git clone https://github.com/zsh-users/zsh-autosuggestions /home/.oh-my-zsh/custom/plugins/zsh-autosuggestions" && \
    sed -i 's~plugins=(~plugins=(zsh-autosuggestions ~g' /home/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20' /home/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_STRATEGY=(history completion)' /home/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_USE_ASYNC=1' /home/.zshrc && \
    sed -i '1iTERM=xterm-256color' /home/.zshrc \
  ;fi && \
  if [ ${SHELL_OH_MY_ZSH_ALIASES} = true ]; then \
    echo "" >> /home/.zshrc && \
    echo "# Load Custom Aliases" >> /home/.zshrc && \
    echo "source /home/aliases.sh" >> /home/.zshrc && \
    echo "" >> /home/.zshrc \
  ;fi \
;fi



###########################################################################
# ZSH User Aliases
###########################################################################

USER root

COPY ./.docker/aliases.sh /root/aliases.sh
COPY ./.docker/aliases.sh /home/aliases.sh

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/aliases.sh && \
    chown $user:$user /home/aliases.sh && \
    echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
	  echo "" >> ~/.zshrc \
;fi

USER root

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
	  echo "" >> ~/.zshrc \
;fi

# Set working directory
WORKDIR /var/www

# Copy custom configurations PHP
COPY .docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

USER root
