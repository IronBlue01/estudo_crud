FROM php:8.1-fpm

# set your user name, ex: user=bernardo
ARG user=infra
ARG uid=1000

#RUN chmod -R 777 /usr/local/etc/php/
#RUN sed -i  's/^;*\(max_execution_time\).*/\1 = 100/' /usr/local/etc/php/php.ini-development
#RUN sed -i  's/^;*\(max_execution_time\).*/\1 = 100/' /usr/local/etc/php/php.ini-production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    unzip \
    git \
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

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd sockets
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user


###########################################################################
# Oh My ZSH!
###########################################################################

USER root

ARG SHELL_OH_MY_ZSH=true

ARG SHELL_OH_MY_ZSH_AUTOSUGESTIONS=true
ARG SHELL_OH_MY_ZSH_ALIASES=true

USER $user
RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc" && \
    sed -i -r 's/^plugins=\(.*?\)$/plugins=(laravel5)/' /home/$user/.zshrc && \
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
bindkey "^?" backward-delete-char\n' >> /home/$user/.zshrc && \
  if [ ${SHELL_OH_MY_ZSH_AUTOSUGESTIONS} = true ]; then \
    sh -c "git clone https://github.com/zsh-users/zsh-autosuggestions /home/$user/.oh-my-zsh/custom/plugins/zsh-autosuggestions" && \
    sed -i 's~plugins=(~plugins=(zsh-autosuggestions ~g' /home/$user/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20' /home/$user/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_STRATEGY=(history completion)' /home/$user/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_USE_ASYNC=1' /home/$user/.zshrc && \
    sed -i '1iTERM=xterm-256color' /home/$user/.zshrc \
  ;fi && \
  if [ ${SHELL_OH_MY_ZSH_ALIASES} = true ]; then \
    echo "" >> /home/$user/.zshrc && \
    echo "# Load Custom Aliases" >> /home/$user/.zshrc && \
    echo "source /home/$user/aliases.sh" >> /home/$user/.zshrc && \
    echo "" >> /home/$user/.zshrc \
  ;fi \
;fi

USER root

###########################################################################
# ZSH User Aliases
###########################################################################

USER root

COPY ./.docker/aliases.sh /root/aliases.sh
COPY ./.docker/aliases.sh /home/$user/aliases.sh

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/$user/aliases.sh && \
    chown $user:$user /home/$user/aliases.sh && \
    echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
	  echo "" >> ~/.zshrc \
;fi

USER $user

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

USER $user
