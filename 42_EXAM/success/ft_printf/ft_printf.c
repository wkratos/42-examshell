
#include <unistd.h>
#include <stdarg.h>

static int ft_putchar(char c){
    return write(1, &c, 1);
}
static int ft_putstr(char *s){
    int count = 0;
    if (!s)
        return ft_putstr("(null)");
    while (s[count])
        write(1, &s[count++],1);
    return count;
}
static int ft_putnbr(int n){
    int count = 0;
    if (n == -2147483648)
        return ft_putstr("-2147483648");
    if (n < 0){
        count += ft_putchar('-');
        n = -n;
    }
    if (n >= 10){
        count += ft_putnbr(n / 10);
    } 
    return count + ft_putchar(n % 10 + '0');
}
static int ft_puthex(unsigned int n){
    int count = 0;
    char *hex = "0123456789abcdef";
    if (n >= 16)
        count += ft_puthex(n / 16);
    return count + ft_putchar(hex[n % 16]);
}

int ft_printf(const char *format, ... ){
    int count = 0;
    va_list args;
    va_start(args, format);
    while(*format){
        if (*format == '%'){
            format++;
            if (*format == 's')
                count += ft_putstr(va_arg(args, char *));
            else if (*format == 'd')
                count += ft_putnbr(va_arg(args, int));
            else if (*format == 'x')
                count += ft_puthex(va_arg(args, unsigned int));
            else
                count +=  ft_putchar(*format);

        }else
            count += ft_putchar(*format);
        format++;
    }
    va_end(args);
    return count;
}
